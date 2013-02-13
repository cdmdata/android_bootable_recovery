#!/bin/bash -e

echo "Creating a signed update.zip."
echo "Android Path: $1"
echo "update package dir: $2"

current_dir=`pwd`

android_path=$1
update_path=$2
utc_stamp=$3

if [ -z $android_path ]; then
    usage
fi

if [ -z $update_path ]; then
    usage
fi

if [ -z $utc_stamp ]; then
    usage
fi

echo "Checking package..."
cd $update_path;
if [ ! -f META-INF/com/google/android/updater-script ]; then
    echo "Error: Your package not have this file:"
    echo "META-INF/com/google/android/updater-script"
    echo "please check, notice the file name is: updater-script, not old update-script"
    cd - >/dev/null
    return
fi

if [ ! -f META-INF/com/google/android/update-binary ]; then
    echo "Error: Your package not have this file:"
    echo "META-INF/com/google/android/update-binary"
    echo "please check."
    cd - >/dev/null
    return
fi

cd - >/dev/null

rm -f update-n.zip update.zip 

java -jar $android_path/out/host/linux-x86/framework/dumpkey.jar $android_path/build/target/product/security/testkey.x509.pem > keys
cp keys $update_path/res/
rm keys
(cd $update_path
    zip -rq $current_dir/update-n.zip * res system files META-INF
)
echo "Signing..."
java -jar  $android_path/out/host/linux-x86/framework/signapk.jar  -w $android_path/build/target/product/security/testkey.x509.pem $android_path/build/target/product/security/testkey.pk8 $current_dir/update-n.zip $current_dir/update_$utc_stamp.zip

rm update-n.zip
echo "Done."
echo "Your update is under:$current_dir/update_$utc_stamp.zip"

function usage {
    echo "usage:"
    echo "make_update_zip.sh Your_android_path Your_update_package_file_path utc-timestamp"
    echo "eg: make_update_zip.sh ~/android/gingerbread/ ~/android/update/ 1359396313"
}
	


