HANDLEBARSC = handlebars

# Build templates javascript
TEMPLATESRC = $(wildcard *.handlebars)
TEMPLATEOBJ = ${TEMPLATESRC:.handlebars=.js}
TEMPLATEOUT = templates.js

$(TEMPLATEOUT): $(TEMPLATEOBJ)
	awk 'FNR==1{print ""}1' $^ > $@

%.js: %.handlebars
	$(HANDLEBARSC) $< -f $@

.PHONY: template
template: $(TEMPLATEOUT)

.PHONY: clean
clean:
	-rm $(TEMPLATEOBJ)
	-rm $(TEMPLATEOUT)
