.PHONY: all clean
all: style.ml content.ml
	mv style.ml content.ml ../

style.ml: style.css
	echo 'let data = "' > style.ml
	cat style.css | sed -e 's/"/\\"/g' >> style.ml
	echo '"' >> style.ml

content.ml: content.md
	echo 'let data = "' > content.ml
	omd content.md | sed -e 's/"/\\"/g' >> content.ml
	echo '"' >> content.ml

clean:
	-rm content.ml style.ml
