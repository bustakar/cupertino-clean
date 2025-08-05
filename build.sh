#!/bin/bash

# Build and run CupertinoClean app
echo "Building CupertinoClean app..."

# Build the project
xcodebuild -project CupertinoClean.xcodeproj -scheme CupertinoClean -configuration Debug build

if [ $? -eq 0 ]; then
    echo "Build successful! Opening app..."
    open /Users/karelbusta/Library/Developer/Xcode/DerivedData/CupertinoClean-eqjnfacjtdgcmubxdtsjdnfjyipd/Build/Products/Debug/CupertinoClean.app
else
    echo "Build failed!"
    exit 1
fi 