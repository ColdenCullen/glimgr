module path;

import io = std.stdio, file = std.file, std.path, std.json, std.getopt, std.conv;
import derelict.freeimage.freeimage;

void main( string[] args )
{
	if( args.length == 1 )
	{
		printUsage();
		return;
	}

	DerelictFI.load();

	string filePath = args[ $ - 1 ];

	string outfile = filePath.absolutePath().stripExtension() ~ ".json";
	getopt( args,
	        "outfile|o", &outfile );

	filePath ~= "\0";
	auto imageData = FreeImage_ConvertTo32Bits( FreeImage_Load( FreeImage_GetFileType( filePath.ptr, 0 ), filePath.ptr, 0 ) );

	uint width = FreeImage_GetWidth( imageData );
	uint height = FreeImage_GetHeight( imageData );

	JSONValue* json = new JSONValue( ["data": ""] );
	json.object[ "data" ]		= (FreeImage_GetBits( imageData ))[ 0..width*height*4 ].to!string;
	json.object[ "width" ]		= width;	
	json.object[ "height" ]		= height;

	io.writeln( outfile );
	file.write( outfile, json.toJSON( true ) );
	
	FreeImage_Unload( imageData );
	destroy( json );
}

void printUsage()
{
	io.writeln( "Example:\nglimgr -o=test.json test.png" );
}
