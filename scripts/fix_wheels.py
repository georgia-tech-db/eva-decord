import os
import shutil
import zipfile
import argparse


METADATA_STR = '''Metadata-Version: 2.1
Name: {}
Version: {}
Summary: EVA's Decord Video Loader
Home-page: https://github.com/georgia-tech-db/eva-decord
Maintainer: Decord committers
Maintainer-email: georgia.tech.db@gmail.com
License: APACHE
Classifier: Development Status :: 3 - Alpha
Classifier: Programming Language :: Python :: 3
Classifier: License :: OSI Approved :: Apache Software License
Requires-Python: >=3.7.0
Requires-Dist: numpy (>=1.14.0)

'''

WHEEL_STR = '''Wheel-Version: 1.0
Generator: bdist_wheel (0.36.2)
Root-Is-Purelib: false
Tag: {}
'''

def process_wheels(dir_path, force_package_name = 'eva-decord', force_version = '0.7.0'):
    os.chdir(dir_path)
    for filename in os.listdir('.'):
        if filename.endswith('.whl'):
            # Unzip the wheel
            name_of_wheel = filename[:-4] # strips the .whl
            print ("Unzipping: " + name_of_wheel)
            package_name, package_version, python_version, abi_tag, platform_tag = name_of_wheel.split('-')

            # Even though we are building on macos13, we change to macos11 to make it more compatible
            if platform_tag == 'macosx_13_0_arm64':
                platform_tag = 'macosx_11_0_arm64'

            # Extract the wheel file
            # Adds a folder decord and the dist-info folder
            with zipfile.ZipFile(filename, 'r') as zip_ref: 
                zip_ref.extractall(name_of_wheel)

            dist_info_dir = f"{package_name.replace('-', '_')}-{package_version}.dist-info"

            package_version = force_version

            
            # Edit the METADATA file
            metadata_file = os.path.join(name_of_wheel, dist_info_dir, 'METADATA')
            with open(metadata_file, 'w') as f:
                f.write(METADATA_STR.format(force_package_name, force_version))

            # Edit the WHEEL file
            wheel_file = os.path.join(name_of_wheel, dist_info_dir, 'WHEEL')
            with open(wheel_file, 'w') as f:
                f.write(WHEEL_STR.format(f"{python_version}-{abi_tag}-{platform_tag}"))
            
            # Rename the dist_info_dir
            new_dist_info_dir_name = f"{force_package_name.replace('-', '_')}-{package_version}.dist-info"
            cur_dist_info_dir  = os.path.join(name_of_wheel, dist_info_dir)
            new_dist_info_dir = os.path.join(name_of_wheel, new_dist_info_dir_name)
            os.rename(cur_dist_info_dir, new_dist_info_dir)

            # Zip the directory with the new name
            new_name = f"{force_package_name.replace('-', '_')}-{package_version}-{python_version}-{abi_tag}-{platform_tag}"
            print ("Zipping: " + new_name)
            shutil.make_archive(new_name, 'zip', name_of_wheel)

            # Rename the zip file to .whl
            os.rename(f"{new_name}.zip", f"{new_name}.whl")

            # Remove the unzipped directory
            shutil.rmtree(name_of_wheel)

            if filename != f"{new_name}.whl":
                # Remove the original wheel
                os.remove(filename)

if __name__ == "__main__":
    # take directory, package name, and version as arguments
    parser = argparse.ArgumentParser()
    parser.add_argument("dir_path", help="Directory containing the wheels to be renamed")
    parser.add_argument("--force_package_name", help="Package name to be used in the renamed wheel", default='eva-decord')
    parser.add_argument("--force_version", help="Version to be used in the renamed wheel", default='0.7.0')
    args = parser.parse_args()
    process_wheels(args.dir_path, args.force_package_name, args.force_version)