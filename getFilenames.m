function imageFilenames = getFilenames(directory, fileFilter)
    D = dir([directory fileFilter]);
    imageFilenames = {};
    for i=1:length(D)
       imageFilenames{i} = [directory D(i).name];
    end
end