/* Include once through an application's tiny_npu.c compilation wrapper.
 * This unique name survives XSCT importsources relocation without matching
 * the application wrapper's basename. Do not compile it again as a library TU.
 */
#include "npu_runtime.c"
#include "tiny_npu.c"
#ifndef EDGE_HOST_TEST
#include "npu_zynq.c"
#endif
