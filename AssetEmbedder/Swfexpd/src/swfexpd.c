/* swfexpd
   Shows the exports in a swf

   Essentially a stripped down swfdump, part of the swftools package.
   Stripping by Andrew Pellerano <yayitsandrew@gmail.com>
   (look mom, I'm a stripper)
   
   Original swfdump is:
   Copyright (c) 2001 Matthias Kramm <kramm@quiss.org>
 
   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

#include "config.h"
#include <stdio.h>
#include <fcntl.h>
#include "swftools/rfxswf.h"
#ifndef WIN32
#include <unistd.h>
#else
#include <io.h>
#endif

void handleExportAssets( TAG* tag )
{
	int num;
	U16 id;
	char* name;
	int t;
	
	num = swf_GetU16( tag );
	for( t = 0; t < num; t++ )
	{
		id = swf_GetU16(tag); //if you don't read id name will be wrong
		name = swf_GetString( tag );
		printf( "%s ", name );
	}
}

int main( int argc, char** argv )
{
	SWF swf;
	TAG* tag;
	char* filename = NULL;
	int f;
	char header[3];
	int fl;
	char isflash;
	
	if( argc > 1 )
	{
		filename = argv[1];
	}

	if( !filename )
	{
		fprintf( stderr, "You must supply a filename.\n" );
		return 1;
	}

	f = open( filename, O_RDONLY | O_BINARY );
	if( f < 0 )
	{ 
		char buffer[256];
		sprintf( buffer, "Couldn't open %.200s", filename );
		perror( buffer );
		exit( 1 );
	}	
	
	read( f, header, 3 );
	isflash = ( header[2]=='S' && header[1] == 'W' && header[0] == 'F' )
		|| ( header[2]=='S' && header[1] == 'W' && header[0] == 'C' );
	close( f );

	fl = strlen( filename );
	if( !isflash && fl > 3 && !strcmp( &filename[fl-4], ".abc" ) )
	{
		swf_ReadABCfile( filename, &swf );
	}
	else
	{
		f = open( filename, O_RDONLY | O_BINARY );
		if FAILED( swf_ReadSWF( f, &swf ) )
		{ 
			fprintf( stderr, "%s is not a valid SWF file or contains errors.\n", filename );
			close( f );
			exit( 1 );
		}
	}
	
	tag = swf.firstTag;
	
	while( tag )
	{
		if(tag->id == ST_EXPORTASSETS || tag->id == ST_SYMBOLCLASS )
		{
			handleExportAssets( tag );
		}
		
		tag = tag->next;
		fflush( stdout );
	}
	
	printf( "\n" );
	swf_FreeTags( &swf );
	return 0;
}
