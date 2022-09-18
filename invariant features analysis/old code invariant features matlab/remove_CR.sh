for file in *.tif; do
   mv $file `echo $file | sed 's/_CR//'`;
done;