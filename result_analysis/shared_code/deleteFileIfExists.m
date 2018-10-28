function deleteFileIfExists(fileName)
if exist(fileName,'file') == 2
    delete(fileName)
end
end