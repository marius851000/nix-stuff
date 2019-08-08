{ stdenv, fetchurl, unrar, unzip, glibc, wrapGAppsHook,
	libcxx, libGL, libGLU, SDL2, gcc-unwrapped}:

# TODO: 64 bit only, but there are a 32 bit binary
let
	cachedUnpack = stdenv.mkDerivation rec {
		pname = "prison-architect-unpacked";
		version = "4b";
		src = fetchurl {
			url = "https://the-eye.eu/public/Games/Linux/Prison.Architect.v4b.MULTi26.Linux-OUTLAWS.tar";
			sha256 = "1y0njfq3z7w59jvi9aanlanp0zxbp5mpq1i8y5i4d2mz75j9ixji";
		};

		nativeBuildInputs = [ unrar unzip ];

		unpackPhase = ''
			tar -xf $src
			mv */* .
			rmdir */
			for archive in $(ls *.zip)
			do
				unzip -o $archive
			done
			rm *.zip
			unrar x ol01140a.rar
			rm *.r*
			rm -r lib64 lib
		'';

		installPhase = ''
			mkdir $out
			cp -r . $out
		'';
	};
in
stdenv.mkDerivation rec {
	pname = "prison-architect";
	version = "4b";
	src = cachedUnpack;

	libPath = stdenv.lib.makeLibraryPath [libcxx libGL libGLU SDL2 gcc-unwrapped];

	nativeBuildInputs = [ wrapGAppsHook ];

	prePatch = ''
		substituteInPlace PrisonArchitect --replace '`dirname "$0"`' "$out/share/prisonarchitect"
		chmod +x PrisonArchitect*
		patchelf --set-interpreter ${stdenv.cc.bintools.dynamicLinker} PrisonArchitect.x86_64
	'';

	installPhase = ''
		mkdir -p $out/share/prisonarchitect
		mkdir -p $out/bin
		cp collectables.dat main.dat prisons.dat sounds.dat PrisonArchitect.x86_64 $out/share/prisonarchitect
		cp PrisonArchitect $out/bin/prison-architect
		wrapProgram $out/bin/prison-architect \
			--prefix LD_LIBRARY_PATH : ${libPath}
	'';
}
