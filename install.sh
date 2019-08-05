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

	ecj -sourcepath "$dir" "$dir/${name}.java" -d "$dir" || {
	  echo "Unable to compile $1"; exit
	}
EOF

cat > $java <<-'EOF'
	#!/system/bin/sh

	if [ -z "$1" ] || ! [ -f "${1}.class" ]; then
	  echo "$1 File not Found" >&2
	  exit
	fi

	dir="$(dirname "$(realpath "${1}.class")")"
	tempdir="$dir/tmp$RANDOM"
	mkdir -p "$tempdir"
	name="$(basename "$1")"

	olddir="$(pwd)"
	cd "${dir}"
	dx --dex --output="$tempdir/${name}.dex" "${name}.class" || {
	  echo "Unable to dex classes"; exit
	}
	cd "${olddir}"

	dalvikvm -cp "${tempdir}/${name}.dex" "${name}" || {
	  echo "Unable to run java package"; exit
	}

	rm -rf "$tempdir"
EOF

chmod 755 $javac $java
