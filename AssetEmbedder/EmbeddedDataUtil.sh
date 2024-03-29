#!/bin/sh

[ -z $1 ] || ASSET_URLS=$1
[ -z $2 ] || BLACKLIST=$2
[ -z $ASSET_URLS ] && ASSET_URLS=EmbeddedDataUtilURLs
[ -z $BLACKLIST ] && BLACKLIST=EmbeddedDataUtilBlacklist
ASSET_REL_DIR=../

#Set this to correct Swfexpd
PATH=$PATH:Swfexpd/Darwin/bin

SYMBOLS=()

function embed_sound
{
	asset=$1
	symbolname=`basename $asset | tr ./ __`
	embed=true
	if  [ -e $BLACKLIST ] ; then
		if grep $symbolname $BLACKLIST 2>&1 >/dev/null ; then
			embed=false
		fi
	fi
	if $embed ; then
		echo "                public static var key_${symbolname}:String = \"$asset\";"
		echo "                [Embed(source=\"${ASSET_REL_DIR}$asset\")]"
		echo "                private static var var_$symbolname:Class;"
		echo ""
		SYMBOLS=("${SYMBOLS[@]}" $symbolname)
	fi
}

function embed_bitmap
{
	asset=$1
	symbolname=`basename $asset | tr ./ __`
	embed=true
	if  [ -e $BLACKLIST ] ; then
		if grep $symbolname $BLACKLIST 2>&1 >/dev/null ; then
			embed=false
		fi
	fi
	if $embed ; then
		echo "                public static var key_${symbolname}:String = \"$asset\";"
		echo "                [Embed(source=\"${ASSET_REL_DIR}$asset\")]"
		echo "                private static var var_$symbolname:Class;"
		echo ""
		SYMBOLS=("${SYMBOLS[@]}" $symbolname)
	fi
}

function embed_movie
{
	asset=$1
	bsymbolname=`basename $asset | tr ./ __`
	for moviesymbol in `swfexpd ${ASSET_REL_DIR}$asset 2>/dev/null | tr " " "\n"` ; do
		if [ ! -z $moviesymbol ] ; then
			moviesymbolname=`echo $moviesymbol | tr " " _`
			symbolname=${bsymbolname}_${moviesymbolname}
			embed=true
			if  [ -e $BLACKLIST ] ; then
				if grep $symbolname $BLACKLIST 2>&1 >/dev/null ; then
					embed=false
				fi
			fi
			if $embed ; then
				echo "                public static var key_${symbolname}:String = \"$asset#$moviesymbol\";"
				echo "                [Embed(source=\"${ASSET_REL_DIR}$asset\", symbol=\"$moviesymbol\" )]"
				echo "                private static var var_$symbolname:Class;"
				echo ""
				SYMBOLS=("${SYMBOLS[@]}" $symbolname)
			fi
		fi
	done
}

function embed_generic
{
	asset=$1
	symbolname=`basename $asset | tr ./ __`
	embed=true
	if  [ -e $BLACKLIST ] ; then
		if grep $symbolname $BLACKLIST 2>&1 >/dev/null ; then
			embed=false
		fi
	fi
	if $embed ; then
		echo "                public static var key_${symbolname}:String = \"$asset\";"
		echo "                [Embed(source=\"${ASSET_REL_DIR}$asset\", mimeType=\"application/octet-stream\")]"
		echo "                private static var var_$symbolname:Class;"
		echo ""
		SYMBOLS=("${SYMBOLS[@]}" $symbolname)
	fi
}

function embed 
{
	asset=$1
	case $asset in
		*swf)
			embed_movie $asset;
			;;
		*png)
			embed_bitmap $asset;
			;;
		*jpg)
			embed_bitmap $asset;
			;;
		*gif)
			embed_bitmap $asset;
			;;
		*wav)
			embed_sound $asset;
			;;
		*mp3)
			embed_sound $asset;
			;;
		*)
			embed_generic $asset;
			;;
	esac
}

cat <<EOF
//Embedded Data Cache - so we can skip URL Loading problems
//Autogenerated - do not modify.

package util
{
        import flash.utils.Dictionary;
        import flash.display.Bitmap;
        import flash.media.Sound;
        
        public class EmbeddedDataUtil
        {
EOF
for asset in `cat $ASSET_URLS 2>/dev/null | grep -v ^\# 2>/dev/null` ; do
	if [ ! -z "$asset" ] ; then
		embed $asset
	fi
done

cat <<EOF
                private static var s_cachedData : Dictionary = new Dictionary();

                public static function getData(uri: String , fromCache: Boolean = true):Object {
                        if(fromCache && s_cachedData[uri] != null) {
                        	return s_cachedData[ uri ];
                        } 
                        return populateCache(uri, fromCache);		
                }

                private static function populateCache(uri: String, fromCache: Boolean = true):Object {
                        var found: Boolean = true;
                        var ret: Object = null;
                        if(uri == null || !uri) {
                                return ret;
                        }
EOF
for symbolname in ${SYMBOLS[*]} ; do
	if [ ! -z "$symbolname" ] ; then
		echo "                        else if(uri == key_$symbolname) {"
		echo "                                ret = new var_$symbolname();"
		echo "                        }"
	fi
done

cat <<EOF
                        else {
                                return ret;
                        }
                        if(fromCache && ret != null) {
                                s_cachedData [ uri ] = ret;
                        }
                        return ret;
                }

        }
}
EOF
