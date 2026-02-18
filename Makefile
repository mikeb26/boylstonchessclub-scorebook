numbers := $(shell seq 1 30)
pages   := $(foreach n,$(numbers),1-2)

.PHONY: build
build: 60pages.pdf coverspread.pdf
	echo "Book internal content: 60pages.pdf"
	echo "Book cover: coverspread.pdf"

.PHONY: clean
clean:
	rm -rf page2_unrotated.pdf page2.pdf page1_nologo.pdf page1_trans.pdf page1.pdf page1_and_2.pdf 60pages.pdf logo.pdf blank.pdf coverspread.pdf blank.aux blank.log temp.ps cover.pdf cover.aux cover.log cover.out blank.out

blank.pdf: blank.tex
	pdflatex blank.tex
cover.pdf: cover.tex
	pdflatex cover.tex

coverspread.pdf: blank.pdf cover.pdf
	pdfjam blank.pdf cover.pdf --nup 2x1 --landscape --papersize "{8.52in,11.91in}" --offset "0cm 0cm" --outfile coverspread.pdf

page2_unrotated.pdf: bcc_a5_scoresheet_move51.pdf
	gs -o page2_unrotated.pdf -dBATCH -dNOPAUSE -sDEVICE=pdfwrite -dCompatibilityLevel=1.3 -dColorConversionStrategy=/CMYK -dProcessColorModel=/DeviceCMYK -dDownsampleColorImages=true -dColorImageDownsampleType=/Average -dColorImageResolution=150 -dDownsampleGrayImages=true -dGrayImageDownsampleType=/Average -dGrayImageResolution=150 -c '<</MaxInkCoverage 300>> setdistillerparams' -f bcc_a5_scoresheet_move51.pdf

page2.pdf: page2_unrotated.pdf
	pdftk page2_unrotated.pdf cat 1-endSouth output page2.pdf

page1_nologo.pdf: bcc_a5_scoresheet_move1_nologo.pdf
	gs -o page1_nologo.pdf -dBATCH -dNOPAUSE -sDEVICE=pdfwrite -dCompatibilityLevel=1.3 -dColorConversionStrategy=/CMYK -dProcessColorModel=/DeviceCMYK -dDownsampleColorImages=true -dColorImageDownsampleType=/Average -dColorImageResolution=150 -dDownsampleGrayImages=true -dGrayImageDownsampleType=/Average -dGrayImageResolution=150 -c '<</MaxInkCoverage 300>> setdistillerparams' -f bcc_a5_scoresheet_move1_nologo.pdf

page1_trans.pdf: page1_nologo.pdf logo.pdf
	pdftk page1_nologo.pdf stamp logo.pdf output page1_trans.pdf

page1.pdf: page1_trans.pdf
	pdf2ps page1_trans.pdf temp.ps
	ps2pdf -dPDFSETTINGS=/printer -dColorImageDownsampleType=/Average -dColorImageResolution=400 -dGrayImageDownsampleType=/Average -dGrayImageResolution=400 -dMonoImageDownsampleType=/Subsample -dMonoImageResolution=400 temp.ps page1.pdf
	rm -f temp.ps

page1_and_2.pdf: page1.pdf page2.pdf
	pdftk page1.pdf page2.pdf cat output page1_and_2.pdf

60pages.pdf: page1_and_2.pdf
	pdftk page1_and_2.pdf cat $(pages) output 60pages.pdf

logo.pdf: logo.png
	mkdir -p ~/.config/ImageMagick
	cp policy.xml ~/.config/ImageMagick
	convert -density 300 -size 1748x2481 xc:none \( logo.png -resize 180% \) -gravity northwest -geometry +175+85 -composite logo.pdf
	rm -rf ~/.config/ImageMagick
