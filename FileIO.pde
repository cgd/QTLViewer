/**
* This module is a container for methods that handle I/O for the main module.
*/

/**
* This method is (only) called by loadFile in module QTLViewer.
*
* @param path the file being parsed by loadFile
* @return the modified path to be used for loading supplementary files
*/
String getModifiedPath(String path) {
   String modifiedPath = "";
    
    if (split(path, ".").length == 2) {
        modifiedPath = split(path, ".")[0];
    } else if (split(path, ".").length == 1) {
        modifiedPath = path;
    } else {
        for (int i = 0; i < split(path, ".").length - 2; i++) {
            modifiedPath += split(path, ".")[i] + ".";
        }
        
        if (modifiedPath.length() > 0) {
            modifiedPath = modifiedPath.substring(0, modifiedPath.length() - 1);
        }
    }
    return modifiedPath;
}
