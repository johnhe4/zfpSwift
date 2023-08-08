// swift-tools-version:5.4
import PackageDescription

let package = Package(
   name: "zfp",
   products: [
      .library(
         name: "zfp",
         targets: ["zfp"])
   ],
   targets: [
      .binaryTarget(
         name: "zfp",
         path: "Frameworks/zfp.xcframework"
      ),
   ],
   cLanguageStandard: .c99
)

