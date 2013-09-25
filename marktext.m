function marktext(filepath)

%This function finds all text files in a given directory folder and attempts to mark the top
%and bottom of each page with appropriate markings for document or export control.
%
%filepath = full file path to folder containing text files to be marked(i.e. C:\My Documents)



%Data to insert
topstring = 'Proprietary/FOUO';
bottomstring = 'Proprietary Information';

%get .txt files in directory
filestruct = dir(fullfile(filepath, '*.txt'));

n = max(size(filestruct));
files = cell(1,n);

for i = 1:n;
	files{1,i} = [filepath '\' filestruct(i).name];
end

%Write last line first
for i = 1:n;
	fid = fopen(files{1,i}, 'a+');
	fseek(fid, 0, 'eof');
	fwrite(fid, bottomstring);
	fclose(fid)
end

%Create temp files with correct top line, copy original over, delete temp files
for i = 1:n;
	tempfile = tempname;
	fname = files{1,i};
	fid = fopen(tempfile, 'wt');
	fwrite(fid, sprintf('%s\n\n', topstring));
	fclose(fid);
	
	fr = fopen(fname, 'r+');
	fw = fopen(tempfile, 'at');
	linect = 1;
		while feof(fr) == 0;
			if linect == 25;    %adjust this parameter to affect page size
				tline = bottomstring;
				fwrite(fw, sprintf('%s\f', tline));
				linect = 0;
			elseif linect == 0;
				tline = topstring;
				fwrite(fw, sprintf('%s\n', tline));
				linect = linect + 1;
			else
				tline = fgetl(fr);
				fwrite(fw, sprintf('%s\n', tline));
				linect = linect + 1;
			end
		end
		
	fclose(fw);
	fclose(fr);
	copyfile(tempfile, fname);
	delete(tempfile);
end

