/*
 * Provides atomic load and store functions using either native C11 atomic
 * types and operations if available, or otherwise using fallback
 * implementations (e.g. with GCC where stdatomic.h is not useable from
 * Objective-C).
 *
 * Adopted from FreeBSD's stdatomic.h:
 *
 * Copyright (c) 2011 Ed Schouten <ed@FreeBSD.org>
 *                    David Chisnall <theraven@FreeBSD.org>
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */
#ifndef _GSAtomic_h_
#define _GSAtomic_h_

#if __has_extension(c_atomic) || __has_extension(cxx_atomic)

/*
 * Use native C11 atomic operations. _Atomic() should be defined by the
 * compiler.
 */
#define	atomic_load_explicit(object, order) \
  __c11_atomic_load(object, order)
#define	atomic_store_explicit(object, desired, order) \
  __c11_atomic_store(object, desired, order)

#else

/*
 * No native support for _Atomic(). Place object in structure to prevent
 * most forms of direct non-atomic access.
 */
#define	_Atomic(T) struct { T volatile __val; }
#if __has_builtin(__sync_swap)
/* Clang provides a full-barrier atomic exchange - use it if available. */
#define	atomic_exchange_explicit(object, desired, order) \
  ((void)(order), __sync_swap(&(object)->__val, desired))
#else
/*
 * __sync_lock_test_and_set() is only an acquire barrier in theory (although in
 * practice it is usually a full barrier) so we need an explicit barrier before
 * it.
 */
#define	atomic_exchange_explicit(object, desired, order) \
__extension__ ({ \
  __typeof__(object) __o = (object); \
  __typeof__(desired) __d = (desired); \
  (void)(order); \
  __sync_synchronize(); \
  __sync_lock_test_and_set(&(__o)->__val, __d); \
})
#endif
#define	atomic_load_explicit(object, order) \
  ((void)(order), __sync_fetch_and_add(&(object)->__val, 0))
#define	atomic_store_explicit(object, desired, order) \
  ((void)atomic_exchange_explicit(object, desired, order))

#endif

#ifndef __ATOMIC_SEQ_CST
#define __ATOMIC_SEQ_CST 5
#endif

/*
 * Convenience functions.
 */
#define	atomic_load(object) \
  atomic_load_explicit(object, __ATOMIC_SEQ_CST)
#define	atomic_store(object, desired) \
  atomic_store_explicit(object, desired, __ATOMIC_SEQ_CST)

#endif // _GSAtomic_h_
