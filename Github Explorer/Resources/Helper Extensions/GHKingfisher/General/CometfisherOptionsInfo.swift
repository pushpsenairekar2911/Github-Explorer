



//  GHKingfisher
//  CometChatUIKit
//  Created by CometChat Inc. on 16/10/19.
//  Copyright © 2020 CometChat Inc. All rights reserved.


#if os(macOS)
import AppKit
#else
import UIKit
#endif
    

/// GHKingfisherOptionsInfo is a typealias for [GHKingfisherOptionsInfoItem].
/// You can use the enum of option item with value to control some behaviors of GHKingfisher.
 typealias GHKingfisherOptionsInfo = [GHKingfisherOptionsInfoItem]

extension Array where Element == GHKingfisherOptionsInfoItem {
    static let empty: GHKingfisherOptionsInfo = []
}

/// Represents the available option items could be used in `GHKingfisherOptionsInfo`.
 enum GHKingfisherOptionsInfoItem {
    
    /// GHKingfisher will use the associated `ImageCache` object when handling related operations,
    /// including trying to retrieve the cached images and store the downloaded image to it.
    case targetCache(ImageCache)
    
    /// The `ImageCache` for storing and retrieving original images. If `originalCache` is
    /// contained in the options, it will be preferred for storing and retrieving original images.
    /// If there is no `.originalCache` in the options, `.targetCache` will be used to store original images.
    ///
    /// When using GHKingfisherManager to download and store an image, if `cacheOriginalImage` is
    /// applied in the option, the original image will be stored to this `originalCache`. At the
    /// same time, if a requested final image (with processor applied) cannot be found in `targetCache`,
    /// GHKingfisher will try to search the original image to check whether it is already there. If found,
    /// it will be used and applied with the given processor. It is an optimization for not downloading
    /// the same image for multiple times.
    case originalCache(ImageCache)
    
    /// GHKingfisher will use the associated `ImageDownloader` object to download the requested images.
    case downloader(ImageDownloader)

    /// Member for animation transition when using `UIImageView`. GHKingfisher will use the `ImageTransition` of
    /// this enum to animate the image in if it is downloaded from web. The transition will not happen when the
    /// image is retrieved from either memory or disk cache by default. If you need to do the transition even when
    /// the image being retrieved from cache, set `.forceRefresh` as well.
    case transition(ImageTransition)
    
    /// Associated `Float` value will be set as the priority of image download task. The value for it should be
    /// between 0.0~1.0. If this option not set, the default value (`URLSessionTask.defaultPriority`) will be used.
    case downloadPriority(Float)
    
    /// If set, GHKingfisher will ignore the cache and try to fire a download task for the resource.
    case forceRefresh

    /// If set, GHKingfisher will try to retrieve the image from memory cache first. If the image is not in memory
    /// cache, then it will ignore the disk cache but download the image again from network. This is useful when
    /// you want to display a changeable image behind the same url at the same app session, while avoiding download
    /// it for multiple times.
    case fromMemoryCacheOrRefresh
    
    /// If set, setting the image to an image view will happen with transition even when retrieved from cache.
    /// See `.transition` option for more.
    case forceTransition
    
    /// If set, GHKingfisher will only cache the value in memory but not in disk.
    case cacheMemoryOnly
    
    /// If set, GHKingfisher will wait for caching operation to be completed before calling the completion block.
    case waitForCache
    
    /// If set, GHKingfisher will only try to retrieve the image from cache, but not from network. If the image is
    /// not in cache, the image retrieving will fail with an error.
    case onlyFromCache
    
    /// Decode the image in background thread before using. It will decode the downloaded image data and do a off-screen
    /// rendering to extract pixel information in background. This can speed up display, but will cost more time to
    /// prepare the image for using.
    case backgroundDecode
    
    /// The associated value of this member will be used as the target queue of dispatch callbacks when
    /// retrieving images from cache. If not set, GHKingfisher will use main queue for callbacks.
    @available(*, deprecated, message: "Use `.callbackQueue(CallbackQueue)` instead.")
    case callbackDispatchQueue(DispatchQueue?)

    /// The associated value will be used as the target queue of dispatch callbacks when retrieving images from
    /// cache. If not set, GHKingfisher will use `.mainCurrentOrAsync` for callbacks.
    ///
    /// - Note:
    /// This option does not affect the callbacks for UI related extension methods. You will always get the
    /// callbacks called from main queue.
    case callbackQueue(CallbackQueue)
    
    /// The associated value will be used as the scale factor when converting retrieved data to an image.
    /// Specify the image scale, instead of your screen scale. You may need to set the correct scale when you dealing
    /// with 2x or 3x retina images. Otherwise, GHKingfisher will convert the data to image object at `scale` 1.0.
    case scaleFactor(CGFloat)

    /// Whether all the animated image data should be preloaded. Default is `false`, which means only following frames
    /// will be loaded on need. If `true`, all the animated image data will be loaded and decoded into memory.
    ///
    /// This option is mainly used for back compatibility internally. You should not set it directly. Instead,
    /// you should choose the image view class to control the GIF data loading. There are two classes in GHKingfisher
    /// support to display a GIF image. `AnimatedImageView` does not preload all data, it takes much less memory, but
    /// uses more CPU when display. While a normal image view (`UIImageView` or `NSImageView`) loads all data at once,
    /// which uses more memory but only decode image frames once.
    case preloadAllAnimationData
    
    /// The `ImageDownloadRequestModifier` contained will be used to change the request before it being sent.
    /// This is the last chance you can modify the image download request. You can modify the request for some
    /// customizing purpose, such as adding auth token to the header, do basic HTTP auth or something like url mapping.
    /// The original request will be sent without any modification by default.
    case requestModifier(ImageDownloadRequestModifier)
    
    /// The `ImageDownloadRedirectHandler` contained will be used to change the request before redirection.
    /// This is the possibility you can modify the image download request during redirect. You can modify the request for
    /// some customizing purpose, such as adding auth token to the header, do basic HTTP auth or something like url
    /// mapping.
    /// The original redirection request will be sent without any modification by default.
    case redirectHandler(ImageDownloadRedirectHandler)
    
    /// Processor for processing when the downloading finishes, a processor will convert the downloaded data to an image
    /// and/or apply some filter on it. If a cache is connected to the downloader (it happens when you are using
    /// GHKingfisherManager or any of the view extension methods), the converted image will also be sent to cache as well.
    /// If not set, the `DefaultImageProcessor.default` will be used.
    case processor(ImageProcessor)
    
    /// Supplies a `CacheSerializer` to convert some data to an image object for
    /// retrieving from disk cache or vice versa for storing to disk cache.
    /// If not set, the `DefaultCacheSerializer.default` will be used.
    case cacheSerializer(CacheSerializer)

    /// An `ImageModifier` is for modifying an image as needed right before it is used. If the image was fetched
    /// directly from the downloader, the modifier will run directly after the `ImageProcessor`. If the image is being
    /// fetched from a cache, the modifier will run after the `CacheSerializer`.
    ///
    /// Use `ImageModifier` when you need to set properties that do not persist when caching the image on a concrete
    /// type of `Image`, such as the `renderingMode` or the `alignmentInsets` of `UIImage`.
    case imageModifier(ImageModifier)
    
    /// Keep the existing image of image view while setting another image to it.
    /// By setting this option, the placeholder image parameter of image view extension method
    /// will be ignored and the current image will be kept while loading or downloading the new image.
    case keepCurrentImageWhileLoading
    
    /// If set, GHKingfisher will only load the first frame from an animated image file as a single image.
    /// Loading an animated images may take too much memory. It will be useful when you want to display a
    /// static preview of the first frame from a animated image.
    ///
    /// This option will be ignored if the target image is not animated image data.
    case onlyLoadFirstFrame
    
    /// If set and an `ImageProcessor` is used, GHKingfisher will try to cache both the final result and original
    /// image. GHKingfisher will have a chance to use the original image when another processor is applied to the same
    /// resource, instead of downloading it again. You can use `.originalCache` to specify a cache or the original
    /// images if necessary.
    ///
    /// The original image will be only cached to disk storage.
    case cacheOriginalImage
    
    /// If set and a downloading error occurred GHKingfisher will set provided image (or empty)
    /// in place of requested one. It's useful when you don't want to show placeholder
    /// during loading time but wants to use some default image when requests will be failed.
    case onFailureImage(CFCrossPlatformImage?)
    
    /// If set and used in `ImagePrefetcher`, the prefetching operation will load the images into memory storage
    /// aggressively. By default this is not contained in the options, that means if the requested image is already
    /// in disk cache, GHKingfisher will not try to load it to memory.
    case alsoPrefetchToMemory
    
    /// If set, the disk storage loading will happen in the same calling queue. By default, disk storage file loading
    /// happens in its own queue with an asynchronous dispatch behavior. Although it provides better non-blocking disk
    /// loading performance, it also causes a flickering when you reload an image from disk, if the image view already
    /// has an image set.
    ///
    /// Set this options will stop that flickering by keeping all loading in the same queue (typically the UI queue
    /// if you are using GHKingfisher's extension methods to set an image), with a tradeoff of loading performance.
    case loadDiskFileSynchronously
    
    /// The expiration setting for memory cache. By default, the underlying `MemoryStorage.Backend` uses the
    /// expiration in its config for all items. If set, the `MemoryStorage.Backend` will use this associated
    /// value to overwrite the config setting for this caching item.
    case memoryCacheExpiration(StorageExpiration)
    
    /// The expiration extending setting for memory cache. The item expiration time will be incremented by this
    /// value after access.
    /// By default, the underlying `MemoryStorage.Backend` uses the initial cache expiration as extending
    /// value: .cacheTime.
    ///
    /// To disable extending option at all add memoryCacheAccessExtendingExpiration(.none) to options.
    case memoryCacheAccessExtendingExpiration(ExpirationExtending)
    
    /// The expiration setting for disk cache. By default, the underlying `DiskStorage.Backend` uses the
    /// expiration in its config for all items. If set, the `DiskStorage.Backend` will use this associated
    /// value to overwrite the config setting for this caching item.
    case diskCacheExpiration(StorageExpiration)

    /// The expiration extending setting for disk cache. The item expiration time will be incremented by this value after access.
    /// By default, the underlying `DiskStorage.Backend` uses the initial cache expiration as extending value: .cacheTime.
    /// To disable extending option at all add diskCacheAccessExtendingExpiration(.none) to options.
    case diskCacheAccessExtendingExpiration(ExpirationExtending)
    
    /// Decides on which queue the image processing should happen. By default, GHKingfisher uses a pre-defined serial
    /// queue to process images. Use this option to change this behavior. For example, specify a `.mainCurrentOrAsync`
    /// to let the image be processed in main queue to prevent a possible flickering (but with a possibility of
    /// blocking the UI, especially if the processor needs a lot of time to run).
    case processingQueue(CallbackQueue)
    
    /// Enable progressive image loading, GHKingfisher will use the `ImageProgressive` of
    case progressiveJPEG(ImageProgressive)

    /// The alternative sources will be used when the original input `Source` fails. The `Source`s in the associated
    /// array will be used to start a new image loading task if the previous task fails due to an error. The image
    /// source loading process will stop as soon as a source is loaded successfully. If all `[Source]`s are used but
    /// the loading is still failing, an `imageSettingError` with `alternativeSourcesExhausted` as its reason will be
    /// thrown out.
    ///
    /// This option is useful if you want to implement a fallback solution for setting image.
    ///
    /// User cancellation will not trigger the alternative source loading.
    case alternativeSources([Source])
}

// Improve performance by parsing the input `GHKingfisherOptionsInfo` (self) first.
// So we can prevent the iterating over the options array again and again.
/// The parsed options info used across GHKingfisher methods. Each property in this type corresponds a case member
/// in `GHKingfisherOptionsInfoItem`. When a `GHKingfisherOptionsInfo` sent to GHKingfisher related methods, it will be
/// parsed and converted to a `GHKingfisherParsedOptionsInfo` first, and pass through the internal methods.
 struct GHKingfisherParsedOptionsInfo {

     var targetCache: ImageCache? = nil
     var originalCache: ImageCache? = nil
     var downloader: ImageDownloader? = nil
     var transition: ImageTransition = .none
     var downloadPriority: Float = URLSessionTask.defaultPriority
     var forceRefresh = false
     var fromMemoryCacheOrRefresh = false
     var forceTransition = false
     var cacheMemoryOnly = false
     var waitForCache = false
     var onlyFromCache = false
     var backgroundDecode = false
     var preloadAllAnimationData = false
     var callbackQueue: CallbackQueue = .mainCurrentOrAsync
     var scaleFactor: CGFloat = 1.0
     var requestModifier: ImageDownloadRequestModifier? = nil
     var redirectHandler: ImageDownloadRedirectHandler? = nil
     var processor: ImageProcessor = DefaultImageProcessor.default1
     var imageModifier: ImageModifier? = nil
     var cacheSerializer: CacheSerializer = DefaultCacheSerializer.default1
     var keepCurrentImageWhileLoading = false
     var onlyLoadFirstFrame = false
     var cacheOriginalImage = false
     var onFailureImage: Optional<CFCrossPlatformImage?> = .none
     var alsoPrefetchToMemory = false
     var loadDiskFileSynchronously = false
     var memoryCacheExpiration: StorageExpiration? = nil
     var memoryCacheAccessExtendingExpiration: ExpirationExtending = .cacheTime
     var diskCacheExpiration: StorageExpiration? = nil
     var diskCacheAccessExtendingExpiration: ExpirationExtending = .cacheTime
     var processingQueue: CallbackQueue? = nil
     var progressiveJPEG: ImageProgressive? = nil
     var alternativeSources: [Source]? = nil

    var onDataReceived: [DataReceivingSideEffect]? = nil
    
     init(_ info: GHKingfisherOptionsInfo?) {
        guard let info = info else { return }
        for option in info {
            switch option {
            case .targetCache(let value): targetCache = value
            case .originalCache(let value): originalCache = value
            case .downloader(let value): downloader = value
            case .transition(let value): transition = value
            case .downloadPriority(let value): downloadPriority = value
            case .forceRefresh: forceRefresh = true
            case .fromMemoryCacheOrRefresh: fromMemoryCacheOrRefresh = true
            case .forceTransition: forceTransition = true
            case .cacheMemoryOnly: cacheMemoryOnly = true
            case .waitForCache: waitForCache = true
            case .onlyFromCache: onlyFromCache = true
            case .backgroundDecode: backgroundDecode = true
            case .preloadAllAnimationData: preloadAllAnimationData = true
            case .callbackQueue(let value): callbackQueue = value
            case .scaleFactor(let value): scaleFactor = value
            case .requestModifier(let value): requestModifier = value
            case .redirectHandler(let value): redirectHandler = value
            case .processor(let value): processor = value
            case .imageModifier(let value): imageModifier = value
            case .cacheSerializer(let value): cacheSerializer = value
            case .keepCurrentImageWhileLoading: keepCurrentImageWhileLoading = true
            case .onlyLoadFirstFrame: onlyLoadFirstFrame = true
            case .cacheOriginalImage: cacheOriginalImage = true
            case .onFailureImage(let value): onFailureImage = .some(value)
            case .alsoPrefetchToMemory: alsoPrefetchToMemory = true
            case .loadDiskFileSynchronously: loadDiskFileSynchronously = true
            case .callbackDispatchQueue(let value): callbackQueue = value.map { .dispatch($0) } ?? .mainCurrentOrAsync
            case .memoryCacheExpiration(let expiration): memoryCacheExpiration = expiration
            case .memoryCacheAccessExtendingExpiration(let expirationExtending): memoryCacheAccessExtendingExpiration = expirationExtending
            case .diskCacheExpiration(let expiration): diskCacheExpiration = expiration
            case .diskCacheAccessExtendingExpiration(let expirationExtending): diskCacheAccessExtendingExpiration = expirationExtending
            case .processingQueue(let queue): processingQueue = queue
            case .progressiveJPEG(let value): progressiveJPEG = value
            case .alternativeSources(let sources): alternativeSources = sources
            }
        }

        if originalCache == nil {
            originalCache = targetCache
        }
    }
}

extension GHKingfisherParsedOptionsInfo {
    var imageCreatingOptions: ImageCreatingOptions {
        return ImageCreatingOptions(
            scale: scaleFactor,
            duration: 0.0,
            preloadAll: preloadAllAnimationData,
            onlyFirstFrame: onlyLoadFirstFrame)
    }
}

protocol DataReceivingSideEffect: AnyObject {
    var onShouldApply: () -> Bool { get set }
    func onDataReceived(_ session: URLSession, task: SessionDataTask, data: Data)
}

class ImageLoadingProgressSideEffect: DataReceivingSideEffect {

    var onShouldApply: () -> Bool = { return true }
    
    let block: DownloadProgressBlock

    init(_ block: @escaping DownloadProgressBlock) {
        self.block = block
    }

    func onDataReceived(_ session: URLSession, task: SessionDataTask, data: Data) {
        DispatchQueue.main.async { [weak self] in
            guard let this = self else { return }
            guard this.onShouldApply() else { return }
            guard let expectedContentLength = task.task.response?.expectedContentLength,
                      expectedContentLength != -1 else
            {
                return
            }

            let dataLength: Int64 = Int64(task.mutableData.count)
            this.block(dataLength, expectedContentLength)
        }
    }
}
