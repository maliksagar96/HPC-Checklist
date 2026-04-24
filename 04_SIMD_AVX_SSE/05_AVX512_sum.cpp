#include <immintrin.h>

void add_avx512_mask(float* A, float* B, float* C, int n) {
  int i = 0;

  for (; i + 15 < n; i += 16) {
    __m512 a = _mm512_loadu_ps(&A[i]);
    __m512 b = _mm512_loadu_ps(&B[i]);
    __m512 c = _mm512_add_ps(a, b);
    _mm512_storeu_ps(&C[i], c);
  }

  int remaining = n - i;
  if (remaining > 0) {
    __mmask16 mask = (1 << remaining) - 1;

    __m512 a = _mm512_maskz_loadu_ps(mask, &A[i]);
    __m512 b = _mm512_maskz_loadu_ps(mask, &B[i]);
    __m512 c = _mm512_add_ps(a, b);
    _mm512_mask_storeu_ps(&C[i], mask, c);
  }
}