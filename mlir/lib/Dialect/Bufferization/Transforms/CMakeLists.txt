add_mlir_dialect_library(MLIRBufferizationTransforms
  Bufferize.cpp
  BufferDeallocationSimplification.cpp
  BufferOptimizations.cpp
  BufferResultsToOutParams.cpp
  BufferUtils.cpp
  BufferViewFlowAnalysis.cpp
  DropEquivalentBufferResults.cpp
  EmptyTensorElimination.cpp
  EmptyTensorToAllocTensor.cpp
  FuncBufferizableOpInterfaceImpl.cpp
  LowerDeallocations.cpp
  OneShotAnalysis.cpp
  OneShotModuleBufferize.cpp
  OwnershipBasedBufferDeallocation.cpp
  TensorCopyInsertion.cpp
  OptimizeAllocationLiveness.cpp

  ADDITIONAL_HEADER_DIRS
  ${MLIR_MAIN_INCLUDE_DIR}/mlir/Dialect/Bufferization

  DEPENDS
  MLIRBufferizationPassIncGen
  MLIRBufferizationEnumsIncGen

  LINK_LIBS PUBLIC
  MLIRArithDialect
  MLIRBufferizationDialect
  MLIRCallInterfaces
  MLIRControlFlowInterfaces
  MLIRFuncDialect
  MLIRFunctionInterfaces
  MLIRInferTypeOpInterface
  MLIRIR
  MLIRMemRefDialect
  MLIRPass
  MLIRTensorDialect
  MLIRSCFDialect
  MLIRSideEffectInterfaces
  MLIRSubsetOpInterface
  MLIRTransforms
  MLIRViewLikeInterface
  MLIRSupport
)
