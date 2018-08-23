#ifdef OMPD_SUPPORT
#include "ompd-specific.h"
#include "omptarget-nvptx.h"
/**
   * Declaration of symbols to hold struct size and member offset information
    */

__device__ __shared__ static int ompd_target_initialized;

#define ompd_target_declare_access(t,m) __device__ __shared__ uint64_t ompd_access__##t##__##m##_;
OMPD_FOREACH_ACCESS(ompd_target_declare_access)
#undef ompd_target_declare_access

#define ompd_target_declare_sizeof_member(t,m) __device__ __shared__ uint64_t ompd_sizeof__##t##__##m##_;
    OMPD_FOREACH_ACCESS(ompd_target_declare_sizeof_member)
#undef ompd_target_declare_sizeof_member

#define ompd_target_declare_sizeof(t) __device__ __shared__ uint64_t ompd_sizeof__##t##_;
    OMPD_FOREACH_SIZEOF(ompd_target_declare_sizeof)
#undef ompd_target_declare_sizeof

__device__ __shared__
  uint64_t ompd_access__omptarget_nvptx_TaskDescr__items__threadsInTeam_;

__device__ __shared__
  uint64_t ompd_sizeof__omptarget_nvptx_TaskDescr__items__threadsInTeam_;


__device__ void ompd_init ( void )
{
  if (ompd_target_initialized)
    return;

#define ompd_target_init_access(t,m) ompd_access__##t##__##m##_ = (uint64_t)&(((t*)0)->m);
  OMPD_FOREACH_ACCESS(ompd_target_init_access)
#undef ompd_target_init_access

  ompd_access__omptarget_nvptx_TaskDescr__items__threadsInTeam_ =
          (uint64_t)&(((omptarget_nvptx_TaskDescr*)0)->items.threadsInTeam);

#define ompd_target_init_sizeof_member(t,m) ompd_sizeof__##t##__##m##_ = sizeof(((t*)0)->m);
  OMPD_FOREACH_ACCESS(ompd_target_init_sizeof_member)
#undef ompd_target_init_sizeof_member

  ompd_sizeof__omptarget_nvptx_TaskDescr__items__threadsInTeam_ =
    (uint64_t)sizeof(((omptarget_nvptx_TaskDescr*)0)->items.threadsInTeam);

#define ompd_target_init_sizeof(t) ompd_sizeof__##t##_ = sizeof(t);
  OMPD_FOREACH_SIZEOF(ompd_target_init_sizeof)
#undef ompd_target_init_sizeof

  omptarget_nvptx_threadPrivateContext->ompd_levelZeroParallelInfo.level = 0;
  if (isSPMDMode()) {
    omptarget_nvptx_threadPrivateContext->teamContext.levelZeroTaskDescr
        .ompd_thread_info.enclosed_parallel.parallel_tasks =
            &omptarget_nvptx_threadPrivateContext->levelOneTaskDescr[0];
  } else {
    // generic mode
    omptarget_nvptx_threadPrivateContext->ompd_levelZeroParallelInfo
        .parallel_tasks = &omptarget_nvptx_threadPrivateContext->teamContext
            .levelZeroTaskDescr;
  }

  ompd_target_initialized = 1;
}

INLINE void ompd_init_thread(omptarget_nvptx_TaskDescr *currTaskDescr) {
  currTaskDescr->ompd_thread_info.blockIdx_x = blockIdx.x;
  currTaskDescr->ompd_thread_info.threadIdx_x = threadIdx.x;
}

__device__ void ompd_set_device_specific_thread_state(
    omptarget_nvptx_TaskDescr *taskDescr, omp_state_t state) {
    taskDescr->ompd_thread_info.state = state;
}

__device__ void  ompd_set_device_thread_state(omp_state_t state) {
  ompd_set_device_specific_thread_state(getMyTopTaskDescriptor(), state);
}

__device__ void ompd_init_thread_parallel() {
  omptarget_nvptx_TaskDescr *currTaskDescr = getMyTopTaskDescriptor();
  ompd_init_thread(currTaskDescr);
  ompd_set_device_specific_thread_state(currTaskDescr, omp_state_work_parallel);
}

__device__ void ompd_init_thread_master() {
  omptarget_nvptx_TaskDescr *currTaskDescr = getMyTopTaskDescriptor();
  ompd_init_thread(currTaskDescr);
  ompd_set_device_specific_thread_state(currTaskDescr, omp_state_work_serial);
}

__device__ void ompd_bp_parallel_begin (){ asm (""); }
__device__ void ompd_bp_parallel_end (){ asm (""); }
__device__ void ompd_bp_task_begin (){ asm (""); }
__device__ void ompd_bp_task_end (){ asm (""); }
#endif /* OMPD_SUPPORT */
