{-# LANGUAGE ForeignFunctionInterface, GeneralizedNewtypeDeriving #-}
module Sound.PortAudio.Base (
    -- Functions
    {-
    Pa_GetVersion,
    Pa_GetVersionText,
    -}
) where

#include <portaudio.h>

import Foreign.C.Types
import Foreign.C.String
import Foreign.Ptr
import Foreign.Storable

{- Integral types. -}

newtype PaErrorCode = PaErrorCode { unPaErrorCode :: CInt }
    deriving (Eq, Show, Storable)

newtype PaError = PaError { unPaError :: PaErrorCode }
    deriving (Eq, Show, Storable)

newtype PaDeviceIndex = PaDeviceIndex { unPaDeviceIndex :: CInt }
    deriving (Eq, Show, Storable)

newtype PaHostApiIndex = PaHostApiIndex { unPaHostApiIndex :: CInt }
    deriving (Eq, Show, Storable)

newtype PaHostApiTypeId = PaHostApiTypeId { unPaHostApiTypeId :: CInt }
    deriving (Eq, Show, Storable)

{- Structures -}
data PaHostApiInfo = PaHostApiInfo {
    structVersion :: CInt,
    hostapitype :: PaHostApiTypeId,
    name :: String,
    deviceCount :: CInt,
    defaultInputDevice :: PaDeviceIndex,
    defaultOutputDevice :: PaDeviceIndex
} deriving (Show)

data PaHostErrorInfo = PaHostErrorInfo {
    hostApiType :: PaHostApiTypeId,
    errorCode :: CLong,
    errorText :: String
} deriving (Show)

{- Enumerable values -}
#{enum PaErrorCode, PaErrorCode
    , paNoError = paNoError
    , paNotInitialized = paNotInitialized 
    , paUnanticipatedHostError = paUnanticipatedHostError 
    , paInvalidChannelCount = paInvalidChannelCount 
    , paInvalidSampleRate = paInvalidSampleRate 
    , paInvalidDevice = paInvalidDevice 
    , paInvalidFlag = paInvalidFlag 
    , paSampleFormatNotSupported = paSampleFormatNotSupported 
    , paBadIODeviceCombination = paBadIODeviceCombination 
    , paInsufficientMemory = paInsufficientMemory 
    , paBufferTooBig = paBufferTooBig 
    , paBufferTooSmall = paBufferTooSmall 
    , paNullCallback = paNullCallback 
    , paBadStreamPtr = paBadStreamPtr 
    , paTimedOut = paTimedOut 
    , paInternalError = paInternalError 
    , paDeviceUnavailable = paDeviceUnavailable 
    , paIncompatibleHostApiSpecificStreamInfo = paIncompatibleHostApiSpecificStreamInfo 
    , paStreamIsStopped = paStreamIsStopped 
    , paStreamIsNotStopped = paStreamIsNotStopped 
    , paInputOverflowed = paInputOverflowed 
    , paOutputUnderflowed = paOutputUnderflowed 
    , paHostApiNotFound = paHostApiNotFound 
    , paInvalidHostApi = paInvalidHostApi 
    , paCanNotReadFromACallbackStream = paCanNotReadFromACallbackStream 
    , paCanNotWriteToACallbackStream = paCanNotWriteToACallbackStream 
    , paCanNotReadFromAnOutputOnlyStream = paCanNotReadFromAnOutputOnlyStream 
    , paCanNotWriteToAnInputOnlyStream = paCanNotWriteToAnInputOnlyStream 
    , paIncompatibleStreamHostApi = paIncompatibleStreamHostApi 
    , paBadBufferPtr = paBadBufferPtr 
    }

#{enum PaDeviceIndex, PaDeviceIndex
    , paNoDevice = paNoDevice
    , paUseHostApiSpecificDeviceSpecification = paUseHostApiSpecificDeviceSpecification
    }

#{enum PaHostApiTypeId, PaHostApiTypeId
    , paInDevelopment = paInDevelopment 
    , paDirectSound = paDirectSound 
    , paMME = paMME 
    , paASIO = paASIO 
    , paSoundManager = paSoundManager 
    , paCoreAudio = paCoreAudio 
    , paOSS = paOSS 
    , paALSA = paALSA 
    , paAL = paAL 
    , paBeOS = paBeOS 
    , paWDMKS = paWDMKS 
    , paJACK = paJACK 
    , paWASAPI = paWASAPI 
    , paAudioScienceHPI = paAudioScienceHPI 
    }

{- Functions -}

{- int Pa_GetVersion( void ); -}
foreign import ccall "portaudio.h Pa_GetVersion"
    pa_GetVersion :: IO CInt

{- const char * Pa_GetVersionText( void ); -}
foreign import ccall "portaudio.h Pa_GetVersionText"
    pa_GetVersionText :: IO CString

{- const char * Pa_GetErrorText( PaError errorCode ); -}
foreign import ccall "portaudio.h Pa_GetErrorText"
    pa_GetErrorText :: CInt -> IO CString 

{- PaError Pa_Initialize( void ); -}
foreign import ccall "portaudio.h Pa_Initialize"
    pa_Initialize :: IO CInt

{- PaError Pa_Terminate( void ); -}
foreign import ccall "portaudio.h Pa_Terminate"
    pa_Terminate :: IO CInt

{- PaHostApiIndex Pa_GetHostApiCount( void ); -}
foreign import ccall "portaudio.h Pa_GetHostApiCount"
    pa_GetHostApiCount :: IO CInt

{- PaHostApiIndex Pa_GetDefaultHostApi( void ); -}
foreign import ccall "portaudio.h Pa_GetDefaultHostApi"
    pa_GetDefaultHostApi :: IO CInt

{- const PaHostApiInfo * Pa_GetHostApiInfo( PaHostApiIndex hostApi ); -}
foreign import ccall "portaudio.h Pa_GetHostApiInfo"
    pa_GetHostApiInfo :: CInt -> IO (Ptr PaHostApiInfo)

{- PaHostApiIndex Pa_HostApiTypeIdToHostApiIndex( PaHostApiTypeId type ); -}
foreign import ccall "portaudio.h Pa_HostApiTypeIdToHostApiIndex"
    pa_HostApiDeviceIdToHostApiIndex :: CInt -> CInt

{- PaDeviceIndex Pa_HostApiDeviceIndexToDeviceIndex( PaHostApiIndex hostApi, int hostApiDeviceIndex ); -}
foreign import ccall "portaudio.h Pa_HostApiDeviceIndexToDeviceIndex"
    pa_HostApiDeviceIndexToDeviceIndex :: CInt -> CInt -> CInt

{- Storable Instances for Structures -}
instance Storable PaHostApiInfo where
    sizeOf _ = #{const sizeof(PaHostApiInfo)}
    alignment _ = #{const __alignof__(PaHostApiInfo)}
    peek p = do
        sv <- #{peek PaHostApiInfo, structVersion} p
        ty <- #{peek PaHostApiInfo, type} p
        np <- return $ #{ptr  PaHostApiInfo, name} p :: IO CString
        nm <- peekCString np
        dc <- #{peek PaHostApiInfo, deviceCount} p
        di <- #{peek PaHostApiInfo, defaultInputDevice} p
        dd <- #{peek PaHostApiInfo, defaultOutputDevice} p
        return $ PaHostApiInfo {
            structVersion = sv,
            hostapitype = ty,
            name = nm,
            deviceCount = dc,
            defaultInputDevice = di,
            defaultOutputDevice = dd
        }
    poke p v = error "Bad user! You shouldn't be poking PaHostApiInfo's!"

instance Storable PaHostErrorInfo where
    sizeOf _ = #{const sizeof(PaHostErrorInfo)}
    alignment _ = #{const __alignof__(PaHostErrorInfo)}
    peek p = do
        ha <- #{peek PaHostErrorInfo, hostApiType} p
        ec <- #{peek PaHostErrorInfo, errorCode} p
        ep <- return $ #{ptr PaHostErrorInfo, errorText} p
        et <- peekCString ep
        return $ PaHostErrorInfo {
            hostApiType = ha,
            errorCode = ec,
            errorText = et
        }
