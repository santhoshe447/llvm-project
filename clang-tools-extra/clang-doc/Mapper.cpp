//===-- Mapper.cpp - ClangDoc Mapper ----------------------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "Mapper.h"
#include "Serialize.h"
#include "clang/AST/Comment.h"
#include "clang/Index/USRGeneration.h"
#include "llvm/ADT/StringExtras.h"
#include "llvm/ADT/StringSet.h"
#include "llvm/Support/Mutex.h"
#include "llvm/Support/TimeProfiler.h"

namespace clang {
namespace doc {

static llvm::StringSet<> USRVisited;
static llvm::sys::SmartMutex<true> USRVisitedGuard;

template <typename T> static bool isTypedefAnonRecord(const T *D) {
  if (const auto *C = dyn_cast<CXXRecordDecl>(D)) {
    return C->getTypedefNameForAnonDecl();
  }
  return false;
}

Location MapASTVisitor::getDeclLocation(const NamedDecl *D) const {
  bool IsFileInRootDir;
  llvm::SmallString<128> File =
      getFile(D, D->getASTContext(), CDCtx.SourceRoot, IsFileInRootDir);
  SourceManager &SM = D->getASTContext().getSourceManager();
  int Start = SM.getPresumedLoc(D->getBeginLoc()).getLine();
  int End = SM.getPresumedLoc(D->getEndLoc()).getLine();

  return Location(Start, End, File, IsFileInRootDir);
}

void MapASTVisitor::HandleTranslationUnit(ASTContext &Context) {
  if (CDCtx.FTimeTrace)
    llvm::timeTraceProfilerInitialize(200, "clang-doc");
  TraverseDecl(Context.getTranslationUnitDecl());
  if (CDCtx.FTimeTrace)
    llvm::timeTraceProfilerFinishThread();
}

template <typename T>
bool MapASTVisitor::mapDecl(const T *D, bool IsDefinition) {
  llvm::TimeTraceScope TS("Mapping declaration");
  {
    llvm::TimeTraceScope TS("Preamble");
    // If we're looking a decl not in user files, skip this decl.
    if (D->getASTContext().getSourceManager().isInSystemHeader(
            D->getLocation()))
      return true;

    // Skip function-internal decls.
    if (D->getParentFunctionOrMethod())
      return true;
  }

  std::pair<std::unique_ptr<Info>, std::unique_ptr<Info>> CP;

  {
    llvm::TimeTraceScope TS("emit info from astnode");
    llvm::SmallString<128> USR;
    // If there is an error generating a USR for the decl, skip this decl.
    if (index::generateUSRForDecl(D, USR))
      return true;
    // Prevent Visiting USR twice
    {
      llvm::sys::SmartScopedLock<true> Guard(USRVisitedGuard);
      StringRef Visited = USR.str();
      if (USRVisited.count(Visited) && !isTypedefAnonRecord<T>(D))
        return true;
      // We considered a USR to be visited only when its defined
      if (IsDefinition)
        USRVisited.insert(Visited);
    }
    bool IsFileInRootDir;
    llvm::SmallString<128> File =
        getFile(D, D->getASTContext(), CDCtx.SourceRoot, IsFileInRootDir);
    CP = serialize::emitInfo(D, getComment(D, D->getASTContext()),
                             getDeclLocation(D), CDCtx.PublicOnly);
  }

  auto &[Child, Parent] = CP;

  {
    llvm::TimeTraceScope TS("serialized info into bitcode");
    // A null in place of a valid Info indicates that the serializer is skipping
    // this decl for some reason (e.g. we're only reporting public decls).
    if (Child)
      CDCtx.ECtx->reportResult(llvm::toHex(llvm::toStringRef(Child->USR)),
                               serialize::serialize(Child));
    if (Parent)
      CDCtx.ECtx->reportResult(llvm::toHex(llvm::toStringRef(Parent->USR)),
                               serialize::serialize(Parent));
  }
  return true;
}

bool MapASTVisitor::VisitNamespaceDecl(const NamespaceDecl *D) {
  return mapDecl(D, /*isDefinition=*/true);
}

bool MapASTVisitor::VisitRecordDecl(const RecordDecl *D) {
  return mapDecl(D, D->isThisDeclarationADefinition());
}

bool MapASTVisitor::VisitEnumDecl(const EnumDecl *D) {
  return mapDecl(D, D->isThisDeclarationADefinition());
}

bool MapASTVisitor::VisitCXXMethodDecl(const CXXMethodDecl *D) {
  return mapDecl(D, D->isThisDeclarationADefinition());
}

bool MapASTVisitor::VisitFunctionDecl(const FunctionDecl *D) {
  // Don't visit CXXMethodDecls twice
  if (isa<CXXMethodDecl>(D))
    return true;
  return mapDecl(D, D->isThisDeclarationADefinition());
}

bool MapASTVisitor::VisitTypedefDecl(const TypedefDecl *D) {
  return mapDecl(D, /*isDefinition=*/true);
}

bool MapASTVisitor::VisitTypeAliasDecl(const TypeAliasDecl *D) {
  return mapDecl(D, /*isDefinition=*/true);
}

bool MapASTVisitor::VisitConceptDecl(const ConceptDecl *D) {
  return mapDecl(D, true);
}

bool MapASTVisitor::VisitVarDecl(const VarDecl *D) {
  if (D->isCXXClassMember())
    return true;
  return mapDecl(D, D->isThisDeclarationADefinition());
}

comments::FullComment *
MapASTVisitor::getComment(const NamedDecl *D, const ASTContext &Context) const {
  RawComment *Comment = Context.getRawCommentForDeclNoCache(D);
  // FIXME: Move setAttached to the initial comment parsing.
  if (Comment) {
    Comment->setAttached();
    return Comment->parse(Context, nullptr, D);
  }
  return nullptr;
}

int MapASTVisitor::getLine(const NamedDecl *D,
                           const ASTContext &Context) const {
  return Context.getSourceManager().getPresumedLoc(D->getBeginLoc()).getLine();
}

llvm::SmallString<128> MapASTVisitor::getFile(const NamedDecl *D,
                                              const ASTContext &Context,
                                              llvm::StringRef RootDir,
                                              bool &IsFileInRootDir) const {
  llvm::SmallString<128> File(Context.getSourceManager()
                                  .getPresumedLoc(D->getBeginLoc())
                                  .getFilename());
  IsFileInRootDir = false;
  if (RootDir.empty() || !File.starts_with(RootDir))
    return File;
  IsFileInRootDir = true;
  llvm::SmallString<128> Prefix(RootDir);
  // replace_path_prefix removes the exact prefix provided. The result of
  // calling that function on ("A/B/C.c", "A/B", "") would be "/C.c", which
  // starts with a / that is not needed. This is why we fix Prefix so it always
  // ends with a / and the result has the desired format.
  if (!llvm::sys::path::is_separator(Prefix.back()))
    Prefix += llvm::sys::path::get_separator();
  llvm::sys::path::replace_path_prefix(File, Prefix, "");
  return File;
}

} // namespace doc
} // namespace clang
