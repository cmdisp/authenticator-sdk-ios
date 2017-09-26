//
//  AuthenticatorSDK.h
//
//  Copyright (c) 2017 CM Telecom B.V.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import <UIKit/UIKit.h>

//! Project version number for Authenticator.
FOUNDATION_EXPORT double AuthenticatorVersionNumber;

//! Project version string for Authenticator.
FOUNDATION_EXPORT const unsigned char AuthenticatorVersionString[];

/*
 * Copyright (c) 2004 Apple Computer, Inc. All Rights Reserved.
 *
 * @APPLE_LICENSE_HEADER_START@
 *
 * This file contains Original Code and/or Modifications of Original Code
 * as defined in and that are subject to the Apple Public Source License
 * Version 2.0 (the 'License'). You may not use this file except in
 * compliance with the License. Please obtain a copy of the License at
 * http://www.opensource.apple.com/apsl/ and read it before using this
 * file.
 *
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER
 * EXPRESS OR IMPLIED, AND APPLE HEREBY DISCLAIMS ALL SUCH WARRANTIES,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT.
 * Please see the License for the specific language governing rights and
 * limitations under the License.
 *
 * @APPLE_LICENSE_HEADER_END@
 */

/*
 * CommonDigest.h - common digest routines: MD2, MD4, MD5, SHA1.
 */

#ifndef _CC_COMMON_DIGEST_H_
#define _CC_COMMON_DIGEST_H_

#include <stdint.h>
#include <Availability.h>

#ifdef __cplusplus
extern "C" {
#endif
    
    /*
     * For compatibility with legacy implementations, the *Init(), *Update(),
     * and *Final() functions declared here *always* return a value of 1 (one).
     * This corresponds to "success" in the similar openssl implementations.
     * There are no errors of any kind which can be, or are, reported here,
     * so you can safely ignore the return values of all of these functions
     * if you are implementing new code.
     *
     * The one-shot functions (CC_MD2(), CC_SHA1(), etc.) perform digest
     * calculation and place the result in the caller-supplied buffer
     * indicated by the md parameter. They return the md parameter.
     * Unlike the opensssl counterparts, these one-shot functions require
     * a non-NULL md pointer. Passing in NULL for the md parameter
     * results in a NULL return and no digest calculation.
     */
    
    typedef uint32_t CC_LONG;       /* 32 bit unsigned integer */
    typedef uint64_t CC_LONG64;     /* 64 bit unsigned integer */
    
    /*** MD2 ***/
    
#define CC_MD2_DIGEST_LENGTH    16          /* digest length in bytes */
#define CC_MD2_BLOCK_BYTES      64          /* block size in bytes */
#define CC_MD2_BLOCK_LONG       (CC_MD2_BLOCK_BYTES / sizeof(CC_LONG))
    
    typedef struct CC_MD2state_st
    {
        int num;
        unsigned char data[CC_MD2_DIGEST_LENGTH];
        CC_LONG cksm[CC_MD2_BLOCK_LONG];
        CC_LONG state[CC_MD2_BLOCK_LONG];
    } CC_MD2_CTX;
    
    extern int CC_MD2_Init(CC_MD2_CTX *c)
    __OSX_AVAILABLE_STARTING(__MAC_10_4, __IPHONE_2_0);
    
    extern int CC_MD2_Update(CC_MD2_CTX *c, const void *data, CC_LONG len)
    __OSX_AVAILABLE_STARTING(__MAC_10_4, __IPHONE_2_0);
    
    extern int CC_MD2_Final(unsigned char *md, CC_MD2_CTX *c)
    __OSX_AVAILABLE_STARTING(__MAC_10_4, __IPHONE_2_0);
    
    extern unsigned char *CC_MD2(const void *data, CC_LONG len, unsigned char *md)
    __OSX_AVAILABLE_STARTING(__MAC_10_4, __IPHONE_2_0);
    
    /*** MD4 ***/
    
#define CC_MD4_DIGEST_LENGTH    16          /* digest length in bytes */
#define CC_MD4_BLOCK_BYTES      64          /* block size in bytes */
#define CC_MD4_BLOCK_LONG       (CC_MD4_BLOCK_BYTES / sizeof(CC_LONG))
    
    typedef struct CC_MD4state_st
    {
        CC_LONG A,B,C,D;
        CC_LONG Nl,Nh;
        CC_LONG data[CC_MD4_BLOCK_LONG];
        uint32_t num;
    } CC_MD4_CTX;
    
    extern int CC_MD4_Init(CC_MD4_CTX *c)
    __OSX_AVAILABLE_STARTING(__MAC_10_4, __IPHONE_2_0);
    
    extern int CC_MD4_Update(CC_MD4_CTX *c, const void *data, CC_LONG len)
    __OSX_AVAILABLE_STARTING(__MAC_10_4, __IPHONE_2_0);
    
    extern int CC_MD4_Final(unsigned char *md, CC_MD4_CTX *c)
    __OSX_AVAILABLE_STARTING(__MAC_10_4, __IPHONE_2_0);
    
    extern unsigned char *CC_MD4(const void *data, CC_LONG len, unsigned char *md)
    __OSX_AVAILABLE_STARTING(__MAC_10_4, __IPHONE_2_0);
    
    
    /*** MD5 ***/
    
#define CC_MD5_DIGEST_LENGTH    16          /* digest length in bytes */
#define CC_MD5_BLOCK_BYTES      64          /* block size in bytes */
#define CC_MD5_BLOCK_LONG       (CC_MD5_BLOCK_BYTES / sizeof(CC_LONG))
    
    typedef struct CC_MD5state_st
    {
        CC_LONG A,B,C,D;
        CC_LONG Nl,Nh;
        CC_LONG data[CC_MD5_BLOCK_LONG];
        int num;
    } CC_MD5_CTX;
    
    extern int CC_MD5_Init(CC_MD5_CTX *c)
    __OSX_AVAILABLE_STARTING(__MAC_10_4, __IPHONE_2_0);
    
    extern int CC_MD5_Update(CC_MD5_CTX *c, const void *data, CC_LONG len)
    __OSX_AVAILABLE_STARTING(__MAC_10_4, __IPHONE_2_0);
    
    extern int CC_MD5_Final(unsigned char *md, CC_MD5_CTX *c)
    __OSX_AVAILABLE_STARTING(__MAC_10_4, __IPHONE_2_0);
    
    extern unsigned char *CC_MD5(const void *data, CC_LONG len, unsigned char *md)
    __OSX_AVAILABLE_STARTING(__MAC_10_4, __IPHONE_2_0);
    
    
    /*** SHA1 ***/
    
#define CC_SHA1_DIGEST_LENGTH   20          /* digest length in bytes */
#define CC_SHA1_BLOCK_BYTES     64          /* block size in bytes */
#define CC_SHA1_BLOCK_LONG      (CC_SHA1_BLOCK_BYTES / sizeof(CC_LONG))
    
    typedef struct CC_SHA1state_st
    {
        CC_LONG h0,h1,h2,h3,h4;
        CC_LONG Nl,Nh;
        CC_LONG data[CC_SHA1_BLOCK_LONG];
        int num;
    } CC_SHA1_CTX;
    
    extern int CC_SHA1_Init(CC_SHA1_CTX *c)
    __OSX_AVAILABLE_STARTING(__MAC_10_4, __IPHONE_2_0);
    
    extern int CC_SHA1_Update(CC_SHA1_CTX *c, const void *data, CC_LONG len)
    __OSX_AVAILABLE_STARTING(__MAC_10_4, __IPHONE_2_0);
    
    extern int CC_SHA1_Final(unsigned char *md, CC_SHA1_CTX *c)
    __OSX_AVAILABLE_STARTING(__MAC_10_4, __IPHONE_2_0);
    
    extern unsigned char *CC_SHA1(const void *data, CC_LONG len, unsigned char *md)
    __OSX_AVAILABLE_STARTING(__MAC_10_4, __IPHONE_2_0);
    
    
    /*** SHA224 ***/
#define CC_SHA224_DIGEST_LENGTH     28          /* digest length in bytes */
#define CC_SHA224_BLOCK_BYTES       64          /* block size in bytes */
    
    /* same context struct is used for SHA224 and SHA256 */
    typedef struct CC_SHA256state_st
    {   CC_LONG count[2];
        CC_LONG hash[8];
        CC_LONG wbuf[16];
    } CC_SHA256_CTX;
    
    extern int CC_SHA224_Init(CC_SHA256_CTX *c)
    __OSX_AVAILABLE_STARTING(__MAC_10_4, __IPHONE_2_0);
    
    extern int CC_SHA224_Update(CC_SHA256_CTX *c, const void *data, CC_LONG len)
    __OSX_AVAILABLE_STARTING(__MAC_10_4, __IPHONE_2_0);
    
    extern int CC_SHA224_Final(unsigned char *md, CC_SHA256_CTX *c)
    __OSX_AVAILABLE_STARTING(__MAC_10_4, __IPHONE_2_0);
    
    extern unsigned char *CC_SHA224(const void *data, CC_LONG len, unsigned char *md)
    __OSX_AVAILABLE_STARTING(__MAC_10_4, __IPHONE_2_0);
    
    
    /*** SHA256 ***/
    
#define CC_SHA256_DIGEST_LENGTH     32          /* digest length in bytes */
#define CC_SHA256_BLOCK_BYTES       64          /* block size in bytes */
    
    extern int CC_SHA256_Init(CC_SHA256_CTX *c)
    __OSX_AVAILABLE_STARTING(__MAC_10_4, __IPHONE_2_0);
    
    extern int CC_SHA256_Update(CC_SHA256_CTX *c, const void *data, CC_LONG len)
    __OSX_AVAILABLE_STARTING(__MAC_10_4, __IPHONE_2_0);
    
    extern int CC_SHA256_Final(unsigned char *md, CC_SHA256_CTX *c)
    __OSX_AVAILABLE_STARTING(__MAC_10_4, __IPHONE_2_0);
    
    extern unsigned char *CC_SHA256(const void *data, CC_LONG len, unsigned char *md)
    __OSX_AVAILABLE_STARTING(__MAC_10_4, __IPHONE_2_0);
    
    
    /*** SHA384 ***/
    
#define CC_SHA384_DIGEST_LENGTH     48          /* digest length in bytes */
#define CC_SHA384_BLOCK_BYTES      128          /* block size in bytes */
    
    /* same context struct is used for SHA384 and SHA512 */
    typedef struct CC_SHA512state_st
    {   CC_LONG64 count[2];
        CC_LONG64 hash[8];
        CC_LONG64 wbuf[16];
    } CC_SHA512_CTX;
    
    extern int CC_SHA384_Init(CC_SHA512_CTX *c)
    __OSX_AVAILABLE_STARTING(__MAC_10_4, __IPHONE_2_0);
    
    extern int CC_SHA384_Update(CC_SHA512_CTX *c, const void *data, CC_LONG len)
    __OSX_AVAILABLE_STARTING(__MAC_10_4, __IPHONE_2_0);
    
    extern int CC_SHA384_Final(unsigned char *md, CC_SHA512_CTX *c)
    __OSX_AVAILABLE_STARTING(__MAC_10_4, __IPHONE_2_0);
    
    extern unsigned char *CC_SHA384(const void *data, CC_LONG len, unsigned char *md)
    __OSX_AVAILABLE_STARTING(__MAC_10_4, __IPHONE_2_0);
    
    
    /*** SHA512 ***/
    
#define CC_SHA512_DIGEST_LENGTH     64          /* digest length in bytes */
#define CC_SHA512_BLOCK_BYTES      128          /* block size in bytes */
    
    extern int CC_SHA512_Init(CC_SHA512_CTX *c)
    __OSX_AVAILABLE_STARTING(__MAC_10_4, __IPHONE_2_0);
    
    extern int CC_SHA512_Update(CC_SHA512_CTX *c, const void *data, CC_LONG len)
    __OSX_AVAILABLE_STARTING(__MAC_10_4, __IPHONE_2_0);
    
    extern int CC_SHA512_Final(unsigned char *md, CC_SHA512_CTX *c)
    __OSX_AVAILABLE_STARTING(__MAC_10_4, __IPHONE_2_0);
    
    extern unsigned char *CC_SHA512(const void *data, CC_LONG len, unsigned char *md)
    __OSX_AVAILABLE_STARTING(__MAC_10_4, __IPHONE_2_0);
    
    /*
     * To use the above digest functions with existing code which uses
     * the corresponding openssl functions, #define the symbol
     * COMMON_DIGEST_FOR_OPENSSL in your client code (BEFORE including
     * this file), and simply link against libSystem (or System.framework)
     * instead of libcrypto.
     *
     * You can *NOT* mix and match functions operating on a given data
     * type from the two implementations; i.e., if you do a CC_MD5_Init()
     * on a CC_MD5_CTX object, do not assume that you can do an openssl-style
     * MD5_Update() on that same context.
     */
    
#ifdef  COMMON_DIGEST_FOR_OPENSSL
    
#define MD2_DIGEST_LENGTH           CC_MD2_DIGEST_LENGTH
#define MD2_CTX                     CC_MD2_CTX
#define MD2_Init                    CC_MD2_Init
#define MD2_Update                  CC_MD2_Update
#define MD2_Final                   CC_MD2_Final
    
#define MD4_DIGEST_LENGTH           CC_MD4_DIGEST_LENGTH
#define MD4_CTX                     CC_MD4_CTX
#define MD4_Init                    CC_MD4_Init
#define MD4_Update                  CC_MD4_Update
#define MD4_Final                   CC_MD4_Final
    
#define MD5_DIGEST_LENGTH           CC_MD5_DIGEST_LENGTH
#define MD5_CTX                     CC_MD5_CTX
#define MD5_Init                    CC_MD5_Init
#define MD5_Update                  CC_MD5_Update
#define MD5_Final                   CC_MD5_Final
    
#define SHA_DIGEST_LENGTH           CC_SHA1_DIGEST_LENGTH
#define SHA_CTX                     CC_SHA1_CTX
#define SHA1_Init                   CC_SHA1_Init
#define SHA1_Update                 CC_SHA1_Update
#define SHA1_Final                  CC_SHA1_Final
    
#define SHA224_DIGEST_LENGTH        CC_SHA224_DIGEST_LENGTH
#define SHA256_CTX                  CC_SHA256_CTX
#define SHA224_Init                 CC_SHA224_Init
#define SHA224_Update               CC_SHA224_Update
#define SHA224_Final                CC_SHA224_Final
    
#define SHA256_DIGEST_LENGTH        CC_SHA256_DIGEST_LENGTH
#define SHA256_Init                 CC_SHA256_Init
#define SHA256_Update               CC_SHA256_Update
#define SHA256_Final                CC_SHA256_Final
    
#define SHA384_DIGEST_LENGTH        CC_SHA384_DIGEST_LENGTH
#define SHA512_CTX                  CC_SHA512_CTX
#define SHA384_Init                 CC_SHA384_Init
#define SHA384_Update               CC_SHA384_Update
#define SHA384_Final                CC_SHA384_Final
    
#define SHA512_DIGEST_LENGTH        CC_SHA512_DIGEST_LENGTH
#define SHA512_Init                 CC_SHA512_Init
#define SHA512_Update               CC_SHA512_Update
#define SHA512_Final                CC_SHA512_Final
    
    
#endif  /* COMMON_DIGEST_FOR_OPENSSL */
    
    /*
     * In a manner similar to that described above for openssl
     * compatibility, these macros can be used to provide compatiblity
     * with legacy implementations of MD5 using the interface defined
     * in RFC 1321.
     */
    
#ifdef  COMMON_DIGEST_FOR_RFC_1321
    
#define MD5_CTX                     CC_MD5_CTX
#define MD5Init                     CC_MD5_Init
#define MD5Update                   CC_MD5_Update
    void MD5Final (unsigned char [16], MD5_CTX *)
    __OSX_AVAILABLE_STARTING(__MAC_10_4, __IPHONE_2_0);
    
#endif  /* COMMON_DIGEST_FOR_RFC_1321 */
    
#ifdef __cplusplus
}
#endif

#endif  /* _CC_COMMON_DIGEST_H_ */

/*
 * Copyright (c) 2004 Apple Computer, Inc. All Rights Reserved.
 *
 * @APPLE_LICENSE_HEADER_START@
 *
 * This file contains Original Code and/or Modifications of Original Code
 * as defined in and that are subject to the Apple Public Source License
 * Version 2.0 (the 'License'). You may not use this file except in
 * compliance with the License. Please obtain a copy of the License at
 * http://www.opensource.apple.com/apsl/ and read it before using this
 * file.
 *
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER
 * EXPRESS OR IMPLIED, AND APPLE HEREBY DISCLAIMS ALL SUCH WARRANTIES,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT.
 * Please see the License for the specific language governing rights and
 * limitations under the License.
 *
 * @APPLE_LICENSE_HEADER_END@
 */

/*!
 @header     CommonHMAC.h
 @abstract   Keyed Message Authentication Code (HMAC) functions.
 */

#ifndef _CC_COMMON_HMAC_H_
#define _CC_COMMON_HMAC_H_

#include <sys/types.h>
#include <Availability.h>

#ifdef __cplusplus
extern "C" {
#endif
    
    /*!
     @enum       CCHmacAlgorithm
     @abstract   Algorithms implemented in this module.
     
     @constant   kCCHmacAlgSHA1      HMAC with SHA1 digest
     @constant   kCCHmacAlgMD5       HMAC with MD5 digest
     @constant   kCCHmacAlgSHA256    HMAC with SHA256 digest
     @constant   kCCHmacAlgSHA384    HMAC with SHA384 digest
     @constant   kCCHmacAlgSHA512    HMAC with SHA512 digest
     @constant   kCCHmacAlgSHA224    HMAC with SHA224 digest
     */
    enum {
        kCCHmacAlgSHA1,
        kCCHmacAlgMD5,
        kCCHmacAlgSHA256,
        kCCHmacAlgSHA384,
        kCCHmacAlgSHA512,
        kCCHmacAlgSHA224
    };
    typedef uint32_t CCHmacAlgorithm;
    
    /*!
     @typedef    CCHmacContext
     @abstract   HMAC context.
     */
#define CC_HMAC_CONTEXT_SIZE    96
    typedef struct {
        uint32_t            ctx[CC_HMAC_CONTEXT_SIZE];
    } CCHmacContext;
    
    /*!
     @function   CCHmacInit
     @abstract   Initialize an CCHmacContext with provided raw key bytes.
     
     @param      ctx         An HMAC context.
     @param      algorithm   HMAC algorithm to perform.
     @param      key         Raw key bytes.
     @param      keyLength   Length of raw key bytes; can be any
     length including zero.
     */
    void CCHmacInit(
                    CCHmacContext *ctx,
                    CCHmacAlgorithm algorithm,
                    const void *key,
                    size_t keyLength)
    __OSX_AVAILABLE_STARTING(__MAC_10_4, __IPHONE_2_0);
    
    
    /*!
     @function   CCHmacUpdate
     @abstract   Process some data.
     
     @param      ctx         An HMAC context.
     @param      data        Data to process.
     @param      dataLength  Length of data to process, in bytes.
     
     @discussion This can be called multiple times.
     */
    void CCHmacUpdate(
                      CCHmacContext *ctx,
                      const void *data,
                      size_t dataLength)
    __OSX_AVAILABLE_STARTING(__MAC_10_4, __IPHONE_2_0);
    
    
    /*!
     @function   CCHmacFinal
     @abstract   Obtain the final Message Authentication Code.
     
     @param      ctx         An HMAC context.
     @param      macOut      Destination of MAC; allocated by caller.
     
     @discussion The length of the MAC written to *macOut is the same as
     the digest length associated with the HMAC algorithm:
     
     kCCHmacAlgSHA1 : CC_SHA1_DIGEST_LENGTH
     
     kCCHmacAlgMD5  : CC_MD5_DIGEST_LENGTH
     */
    void CCHmacFinal(
                     CCHmacContext *ctx,
                     void *macOut)
    __OSX_AVAILABLE_STARTING(__MAC_10_4, __IPHONE_2_0);
    
    
    /*
     * Stateless, one-shot HMAC function.
     * Output is written to caller-supplied buffer, as in CCHmacFinal().
     */
    void CCHmac(
                CCHmacAlgorithm algorithm,  /* kCCHmacAlgSHA1, kCCHmacAlgMD5 */
                const void *key,
                size_t keyLength,           /* length of key in bytes */
                const void *data,
                size_t dataLength,          /* length of data in bytes */
                void *macOut)               /* MAC written here */
    __OSX_AVAILABLE_STARTING(__MAC_10_4, __IPHONE_2_0);
    
#ifdef __cplusplus
}
#endif

#endif  /* _CC_COMMON_HMAC_H_ */
