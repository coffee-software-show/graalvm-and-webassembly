#!/usr/bin/env bash
source "$HOME/.sdkman/bin/sdkman-init.sh"

function setup(){
  if [[ "$OSTYPE" == "darwin"* ]]; then
      platform="darwin"
  elif [[ "$OSTYPE" == "linux"* ]]; then
      platform="linux"
  fi
  arch=$(uname -m)
  if [[ "$arch" == "x86_64" ]]; then
      arch="x64"
  elif [[ "$arch" == "arm64" ]] || [[ "$arch" == "aarch64" ]]; then
      arch="aarch64"
  fi
  json_url="https://raw.githubusercontent.com/graalvm/oracle-graalvm-ea-builds/refs/heads/main/versions/25-ea.json"
  temp_file=$(mktemp)
  curl -s "$json_url" > "$temp_file"
  if [ $? -ne 0 ]; then
      echo "Failed to download version information"
      rm "$temp_file"
      exit 1
  fi
  latest_version=$(jq -r '[.[] | select(.latest == true)] | .[0].version' "$temp_file")
  base_url=$(jq -r --arg version "$latest_version" '[.[] | select(.version == $version)] | .[0].download_base_url' "$temp_file")
  filename=$(jq -r --arg version "$latest_version" --arg arch "$arch" --arg platform "$platform" \
    '[.[] | select(.version == $version)] | .[0].files[] | select(.arch == $arch and .platform == $platform) | .filename' "$temp_file")
  echo $filename
  download_url="${base_url}${filename}"
  curl -o graalvm.tgz -L -O "$download_url"
  OD=temp_extract
  mkdir -p $OD
  tar -xzf graalvm.tgz -C $OD
  cd $OD
  folder=$(  find . -maxdepth 1 -type d -mindepth 1   | head -n1 )
  echo "the folder is $folder "
  mkdir -p $HOME/bin
  install_dir=$HOME/bin/${folder}
  mv $OD/${folder} $install_dir
  sdk install java 25.ea.15-graal $install_dir/Contents/Home
  
}

sdk list java | grep 25.ea.15-graal || setup

