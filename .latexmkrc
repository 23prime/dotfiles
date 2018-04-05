#!/usr/bin/env perl
$latex         = 'uplatex -synctex=1 -halt-on-error -shell-escape';
$latex_silent  = 'uplatex -synctex=1 -halt-on-error -interaction=batchmode -shell-escape';
$bibtex        = 'upbibtex';
$dvipdf        = 'dvipdfmx %O -o %D %S';
$makeindex     = 'mendex %O -o %D %S';
$max_repeat    = 5;
$pdf_mode	     = 3;
$pdf_previewer = "evince";
$pvc_view_file_via_temporary = 0;
