# Flecty

Flecty is a project to mine [Wiktionary](https://www.wiktionary.org/) to create machine-readable morphosyntactic dictionaries.

The dictionaries are intended for use in computational linguistics, e.g. natural language processing, machine assisted translation, natural language production, etc.

## Dictionaries

The morphosyntactic dictionaries generated by Flecty are available in the **out** subfolder within the folder for each language. The dictionaries are XML files which comply with the [dictionaries module](http://www.tei-c.org/release/doc/tei-p5-doc/en/html/DI.html) of the [Text Encoding Initiative](http://www.tei-c.org). More will become available as the project continues.

### Description

Each dictionary contains _only_ inflectional morphology. I’m not interested (for the purposes of this project... yet) in semantics, etymology, or cross-references to other words. See [Wikokit](https://github.com/componavt/wikokit) for another project which mines Wiktionary to create machine-readable dictionaries which may include this kind of information.

### Downloading

Clone the project, or click on **Download Zip** and unzip it to a directory of your
choice.

### Licence

The morphosyntactic dictionaries are released under the [Creative Commons Attribution-ShareAlike 3.0 Unported](http://creativecommons.org/licenses/by-sa/3.0/) licence.

I’ve endeavoured to comply fully with Wiktionary’s terms of use in creating these dictionaries.

### Acknowledgements

Thanks to the contributors and editors of Wiktionary for the linguistic data. Each entry within each dictionary contains a link back to the Wiktionary page from which the linguistic data was mined. Please see those linked Wiktionary pages for details of the authors who wrote and edited the original data.

## Software

I’ve also released the Flecty software used to create the dictionaries, in case anyone is interested to know how I did this, or even wants to try doing it. You don’t need to run Flecty to access any dictionaries that I’ve already created.

### Prerequisites

To run Flecty, you need an XSLT processor compatible with [XSLT 1.0 or
1.1](http://www.w3.org/TR/xslt) and [eXSLT](http://exslt.org/). Flecty works with [Saxon
6.5.5](http://saxon.sourceforge.net/saxon6.5.5/) but does _not_ work with [XSLTProc](http://xmlsoft.org/libxslt/); I haven’t yet worked out why this is.

### Installation

Clone the project, or click on **Download Zip** and unzip it to a directory of your
choice.

### Overview

Each category of words (adjectives, participles, etc.) in each language has a different inflectional paradigm, and therefore requires slightly different markup in the syntactic dictionary. Therefore, it’s easiest to mine each category of words in each language separately. That’s why each category of words in each language is stored in a different file.

Mining Wiktionary is a two-stage process: first, we get a list of all words in a particular category; second, we access each word in turn and get the inflectional morphology. The first step can be done fairly easily using the Wiktionary API. The second step is harder, however. Querying the API for a particular page gives the wiki markup for that page, rather than the HTML that is served to the web. Inflectional paradigms are stored in the wiki markup as wiki templates. And, as described above, each language has different templates for each category of words. It may well be possible to query the API for each inflectional template and build a complete paradigm for each word. However, I decided it would be easier to scrape the HTML source of the page for each word.

The HTML source is parsable as XHTML 5, i.e. it has fully closed tags. I use XSLT to scrape the HTML source for each Witionary entry, since the input is (effectively) XML and I’m transforming it to get XML output.

The English Wiktionary contains many thousands of words from other languages. However the Wiktionary for each particular language contains words in that language which the English Wiktionary doesn’t. So, when I’m creating the dictionary for a selected language, I mine the Wiktionary for that language.

### Preparation

Before you can run Flecty to generate a new dictionary for a category of words in a particular language, you need to create two files:

* An **API call file**. This is an [XML Java Properties](http://docs.oracle.com/javase/7/docs/api/java/util/Properties.html) file. (The choice of this format is not particularly significant; it’s just a handy, established XML format for storing key / value pairs.)

  I’ve stored each of my API call files in the folder for their target language. I’ve named them using the convention **und_call_cat.xml**, where _und_ is the ISO language code of the target language, and _cat_ is an abbreviation representing the category of words to be mined.

  The API call file should start with a `<comment>` element. The content of this will ultimately be used as the title of the dictionary. The convention I’ve used is that it should name the language and category of the words in the output dictionary, in the target language, e.g. _Adjectifs en français_.

  The API call file must contain an `<entry>` element with the `key` attribute set to `API`. This contains the API call used to get the list of words that will be mined. The API call should typically contain the following parameters:

    `action=query` — common to most Wikimedia API calls;

    `format=xml` — because we’re going to transform the results using XSLT;

    `list=categorymembers`

    `cmlimit=500` — the maximum that can be returned at a time;

    `cmtitle=Category` — where _Category_ is the category of words that you want to include in the dictionary, e.g. `Cat%C3%A9gorie:Adjectifs_en_fran%C3%A7ais`. You’ll need to examine the Wiktionary for your chosen language to see the exact name of the category that you want.

  The API call must be a valid XML text node, i.e. ampersands should be escaped as `&amp;`. For more information on Wikimedia API calls, see the [MediaWiki API help](https://en.wiktionary.org/w/api.php).

  The API call file must also contain an `<entry>` element with the `key` attribute set to `NS`. This contains a namespace number, which is used to select the precise type of word returned by the API call.

  The API call files are used by a common transformation file called **Miner.xsl**, which is located in the root folder of the project. This executes the API call and writes the list of results to a word list file. If there are more than 500 responses from the API call, **Miner.xsl** recurses through each of the continuation API calls necessary to fetch the rest of the data.

  The word list file — the output of the API call — is another XML Java properties file. This again contains a `<comment>` element containing the ultimate title of this dictionary. Each `<entry>` element has a `key` attribute containing the unique ID number of the entry on Wiktionary, and contains the title of its Wiktionary page.

  I store the word list files in the **data** subfolder within the folder for their target language. I’ve named them using the convention **und_list_cat.xml**, where _und_ is the ISO language code of the target language, and _cat_ is an abbreviation representing the category of words to be mined.

* A **transformation file**. This is an XSLT transformation which looks at each of the specified pages on Wiktionary in turn, takes the HTML source of each page, finds the inflectional morphology, and transforms it into machine-readable TEI output.

  I’ve stored each of my transformation files in the folder for its target language. I’ve named them using the convention **und_scrape_cat.xsl**, where _und_ is the ISO language code of the target language and _cat_ is an abbreviation representing the category of words to be mined.

  Needless to say, writing this file is the tricky bit. You’ll need a basic understanding of the inflectional morphology of this category of words in this particular language. You’ll need to examine the HTML source of several Wiktionary pages for this category of words in this particular language, to see how the inflectional morphology is encoded. You’ll also need a good knowledge of XSLT and TEI to write the transformations. Unfortunately, this goes way beyond the scope of this file. For now, I can only suggest looking at the existing transformations for help.

  The transformation files all import a common transformation file called **Scraper.xsl**, which is located in the root folder of the project. This writes the TEI metadata for the output dictionary and handles the process of opening each of the specified pages on Wiktionary in turn.

### Running

In these examples, _und_ is the ISO language code of the language whose Wiktionary you are mining, e.g. **fr** for French; and _cat_ is an abbreviation representing the category of words whose inflectional morphology you are mining, e.g. **adj** for adjectives.

Step 1: Query the Wiktionary API to generate a list of words in a particular category:

<pre>
	java com.icl.saxon.StyleSheet -o <i>und</i>/data/<i>und</i>_list_<i>cat</i>.xml \
	                              <i>und</i>/<i>und</i>_call_<i>cat</i>.xml \
	                              Miner.xsl
</pre>

The list of words is stored in the **data** folder for this language.

Step 2: Scrape the Wiktionary entry for each word in turn to find the infectional morphology:

<pre>
	java com.icl.saxon.StyleSheet -o <i>und</i>/out/<i>und</i>_dict_<i>cat</i>.xml \
	                              <i>und</i>/data/<i>und</i>_list_<i>cat</i>.xml \
	                              <i>und</i>/<i>und</i>_scrape_<i>cat</i>.xsl \
</pre>

The dictionary is stored in the **out** folder for this language.

### Licence

The Flecty program, i.e. the XML call files and the XSLT stylesheets, are released under the LGPL. See the **LICENSE** file.

### Contributions

Contributions are welcome. Please fork the code and send a pull request!

