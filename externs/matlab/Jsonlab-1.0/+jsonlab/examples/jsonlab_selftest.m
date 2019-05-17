%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         Regression Test Unit of loadjson and savejson
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i=1:4
    fname=sprintf('example%d.json',i);
    if(exist(fname,'file')==0) break; end
    fprintf(1,'===============================================\n>> %s\n',fname);
    json=jsonlab.savejson('data',jsonlab.loadjson(fname));
    fprintf(1,'%s\n',json);
    fprintf(1,'%s\n',jsonlab.savejson('data',jsonlab.loadjson(fname),'Compact',1));
    data=jsonlab.loadjson(json);
    jsonlab.savejson('data',data,'selftest.json');
    data=jsonlab.loadjson('selftest.json');
end

for i=1:4
    fname=sprintf('example%d.json',i);
    if(exist(fname,'file')==0) break; end
    fprintf(1,'===============================================\n>> %s\n',fname);
    json=jsonlab.saveubjson('data',jsonlab.loadjson(fname));
    fprintf(1,'%s\n',json);
    data=jsonlab.loadubjson(json);
    jsonlab.savejson('',data);
    jsonlab.saveubjson('data',data,'selftest.ubj');
    data=jsonlab.loadubjson('selftest.ubj');
end
