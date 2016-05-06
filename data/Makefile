.PHONY: all clean
all: style.ml content.ml
	mv style.ml content.ml ../

style.ml: style.css
	echo 'let data = {___|' > style.ml
	cat style.css >> style.ml
	echo '|___}' >> style.ml

content.ml: content.md
	echo 'let data = {___|' > content.ml
	omd content.md >> content.ml
	echo '|___}' >> content.ml

clean:
	-rm content.ml style.ml
