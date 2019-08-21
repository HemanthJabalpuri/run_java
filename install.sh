#!/data/data/com.termux/files/usr/bin/bash

javac=/data/data/com.termux/files/usr/bin/javac
java=/data/data/com.termux/files/usr/bin/java

cat > $javac <<-'EOF'
	#!/system/bin/sh

	if [ -z "$1" ] || ! [ -f "$1" ]; then
	  echo "$1 File not Found" >&2
	  exit
	elif [ -z "$(command -v ecj)" ] || [ -z "$(command -v dx)" ]; then
	  echo "ecj/dx not Found" >&2
	  exit
	fi

	dir="$(dirname "$(realpath "$1")")"
	name="$(basename "$1" .java)"
	tempdir="$dir/tmp$RANDOM"

	ecj -sourcepath "$dir" "$dir/${name}.java" -d "$tempdir" || {
	  echo "Unable to compile $1"; exit
	}

	cd "$tempdir"
	dx --dex --output="$dir/${name}.dex" * || {
	  echo "Unable to dex classes"; exit
	}

	rm -rf "$tempdir"
EOF

cat > $java <<-'EOF'
	#!/system/bin/sh

	if [ -z "$1" ] || ! [ -f "${1}.dex" ]; then
	  echo "$1 File not Found" >&2
	  exit
	fi

	dir="$(dirname "$(realpath "${1}.dex")")"
	name="$(basename "$1")"; shift

	dalvikvm -cp "${dir}/${name}.dex" "${name}" "$@" || {
	  echo "Unable to run java package"; exit
	}
EOF

chmod 755 $javac $java
