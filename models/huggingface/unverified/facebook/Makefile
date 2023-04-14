# -*-makefile-*-


PWD      := ${shell pwd}
REPOHOME := ${PWD}/../../../


MODEL_NAME = nllb-200-54.5B
USER_NAME  = facebook
MODEL_URL  = https://github.com/facebookresearch/fairseq/tree/nllb


MODEL_PARAM = 	USER_NAME=${USER_NAME} USER_MODEL=${MODEL_NAME} \
		MODEL_URL=unverified/${USER_NAME}/${MODEL_NAME}

MODEL_WORKDIR = ../work/unverified/${USER_NAME}/${MODEL_NAME}


all: update ${MODEL_NAME}.txt


include ../../lib/config.mk

FLORES200_LANGS = ace_Arab ace_Latn acm acq aeb afr ajp aka als amh apc ara ara_Latn ars ary arz asm ast awa ayr azb azj bak bam ban bel bem ben bho bjn_Arab bjn_Latn bod bos bug bul cat ceb ces cjk ckb cmn_Hans cmn_Hant crh cym dan deu dik dyu dzo ell eng epo est eus ewe fao fij fin fon fra fur fuv gaz gla gle glg grn guj hat hau heb hin hne hrv hun hye ibo ilo ind isl ita jav jpn kab kac kam kan kas_Arab kas_Deva kat kaz kbp kea khk khm kik kin kir kmb kmr knc_Arab knc_Latn kon kor lao lij lim lin lit lmo ltg ltz lua lug luo lus lvs mag mai mal mar min_Arab min_Latn mkd mlt mni mos mri msa mya nld nno nob npi nso nus nya oci ory pag pan pap pbt pes plt pol por prs quy ron run rus sag san sat scn shn sin slk slv smo sna snd som sot spa srd srp_Cyrl ssw sun swe swh szl tam taq_Latn taq_Tfng tat tel tgk tgl tha tir tpi tsn tso tuk tum tur twi tzm uig ukr umb urd uzn vec vie war wol xho ydd yor yue zsm zul

FLORES200_LANGPAIRS := ${shell for s in ${FLORES200_LANGS}; do for t in ${FLORES200_LANGS}; do echo "$$s-$$t"; done done}
FLORES200_TARGETS := $(patsubst %,flores200-devtest.%,${FLORES200_LANGPAIRS})

model-score-files:
	${MAKE} -C .. ${MODEL_PARAM} fetch-model-scores
	${MAKE} non_flores_translations move-flores-translations move-flores-translations-renamed
	${MAKE} -s eval-wmt-translations eval-flores-translations
	${MAKE} -C .. ${MODEL_PARAM} update-eval-files

update-eval-files:
	${MAKE} -C .. ${MODEL_PARAM} update-eval-files

pack-model-scores: model-score-files
	${MAKE} -C .. ${MODEL_PARAM} pack-model-scores

register: pack-model-scores
	${MAKE} -C ../.. SOURCE=unverified MODEL=${USER_NAME}/${MODEL_NAME} register

update: register
	${MAKE} -C ../../.. all-contributed


.PHONY: infofile
infofile: ${MODEL_NAME}.tsv

${MODEL_NAME}.tsv:
	echo "name	${MODEL_NAME}" > $@
	echo "provider	${USER_NAME}" >> $@
	echo "url	${MODEL_URL}" >> $@
	echo "size	54.5B"        >> $@



eval-wmt-translations: wmt-ces-eng wmt-deu-eng wmt-est-eng wmt-fin-eng wmt-fra-eng \
		wmt-guj-eng wmt-hin-eng wmt-kaz-eng wmt-lit-eng wmt-lav-eng wmt-ron-eng \
		wmt-rus-eng wmt-spa-eng wmt-tur-eng wmt-zho-eng

eval-flores-translations: ${FLORES200_TARGETS}

${FLORES200_TARGETS}:
	@if [ -e ${MODEL_WORKDIR}/$@.output ]; then \
	  ${MAKE} -C .. ${MODEL_PARAM} TESTSETS=flores200-devtest LANGPAIR=$(patsubst flores200-devtest.%,%,$@) eval; \
	fi

# eval-flores-translations: move-flores-translations move-flores-translations-renamed
# 	for s in ${FLORES200_LANGS}; do \
# 	  for t in ${FLORES200_LANGS}; do \
# 	    if [ -e ${MODEL_WORKDIR}/flores200-devtest.$$s-$$t.output ]; then \
# 	      ${MAKE} -C .. ${MODEL_PARAM} TESTSETS=flores200-devtest LANGPAIR=$$s-$$t eval; \
# 	    fi \
# 	  done \
# 	done

flores_translations:
	wget -O $@.zip -qq https://tinyurl.com/nllbflorestranslations
	unzip $@.zip
	rm -f $@.zip

move-flores-translations:
	${MAKE} flores_translations
	@mkdir -p ${MODEL_WORKDIR}
	@for s in ${FLORES200_LANGS}; do \
	  for t in ${FLORES200_LANGS}; do \
	    mv flores_translations/flores200-$${s}-$${t}-devtest.hyp ${MODEL_WORKDIR}/flores200-devtest.$$s-$$t.output 2>/dev/null || \
	    mv flores_translations/flores200-$${s}_*-$${t}-devtest.hyp ${MODEL_WORKDIR}/flores200-devtest.$$s-$$t.output 2>/dev/null || \
	    mv flores_translations/flores200-$${s}-$${t}_*-devtest.hyp ${MODEL_WORKDIR}/flores200-devtest.$$s-$$t.output 2>/dev/null || \
	    mv flores_translations/flores200-$${s}_*-$${t}_*-devtest.hyp ${MODEL_WORKDIR}/flores200-devtest.$$s-$$t.output 2>/dev/null || \
	    echo "skip $${s}-$${t}"; \
	  done \
	done
	@touch $@

move-flores-translations-renamed:
	${MAKE} flores_translations
	@for l in ${FLORES200_LANGS}; do \
	  mv flores_translations/flores200-$${l}-arb_Arab-devtest.hyp ${MODEL_WORKDIR}/flores200-devtest.$$l-ara.output 2>/dev/null || \
	  mv flores_translations/flores200-$${l}_*-arb_Arab-devtest.hyp ${MODEL_WORKDIR}/flores200-devtest.$$l-ara.output 2>/dev/null || \
	  echo "skip $${l}-ara_Arb"; \
	  mv flores_translations/flores200-arb_Arab-$${l}-devtest.hyp ${MODEL_WORKDIR}/flores200-devtest.ara-$$l.output 2>/dev/null || \
	  mv flores_translations/flores200-arb_Arab-$${l}_*-devtest.hyp ${MODEL_WORKDIR}/flores200-devtest.ara-$$l.output 2>/dev/null || \
	  echo "skip ara_Arb-$${l}"; \
	  mv flores_translations/flores200-$${l}-zho_Hans-devtest.hyp ${MODEL_WORKDIR}/flores200-devtest.$$l-cmn_Hans.output 2>/dev/null || \
	  mv flores_translations/flores200-$${l}_*-zho_Hans-devtest.hyp ${MODEL_WORKDIR}/flores200-devtest.$$l-cmn_Hans.output 2>/dev/null || \
	  echo "skip $${l}-zho_Hans"; \
	  mv flores_translations/flores200-zho_Hans-$${l}-devtest.hyp ${MODEL_WORKDIR}/flores200-devtest.cmn_Hans-$$l.output 2>/dev/null || \
	  mv flores_translations/flores200-zho_Hans-$${l}_*-devtest.hyp ${MODEL_WORKDIR}/flores200-devtest.cmn_Hans-$$l.output 2>/dev/null || \
	  echo "skip zho_Hans-$${l}"; \
	  mv flores_translations/flores200-$${l}-zho_Hant-devtest.hyp ${MODEL_WORKDIR}/flores200-devtest.$$l-cmn_Hant.output 2>/dev/null || \
	  mv flores_translations/flores200-$${l}_*-zho_Hant-devtest.hyp ${MODEL_WORKDIR}/flores200-devtest.$$l-cmn_Hant.output 2>/dev/null || \
	  echo "skip $${l}-zho_Hant"; \
	  mv flores_translations/flores200-zho_Hant-$${l}-devtest.hyp ${MODEL_WORKDIR}/flores200-devtest.cmn_Hant-$$l.output 2>/dev/null || \
	  mv flores_translations/flores200-zho_Hant-$${l}_*-devtest.hyp ${MODEL_WORKDIR}/flores200-devtest.cmn_Hant-$$l.output 2>/dev/null || \
	  echo "skip zho_Hant-$${l}"; \
	done
	-@mv flores_translations/flores200-zho_Hant-arb_Arab-devtest.hyp ${MODEL_WORKDIR}/flores200-devtest.cmn_Hant-ara.output
	-@mv flores_translations/flores200-zho_Hans-arb_Arab-devtest.hyp ${MODEL_WORKDIR}/flores200-devtest.cmn_Hans-ara.output
	-@mv flores_translations/flores200-arb_Arab-zho_Hant-devtest.hyp ${MODEL_WORKDIR}/flores200-devtest.ara-cmn_Hant.output
	-@mv flores_translations/flores200-arb_Arab-zho_Hans-devtest.hyp ${MODEL_WORKDIR}/flores200-devtest.ara-cmn_Hans.output
	-@mv flores_translations/flores200-zho_Hant-zho_Hans-devtest.hyp ${MODEL_WORKDIR}/flores200-devtest.cmn_Hant-cmn_Hans.output
	-@mv flores_translations/flores200-zho_Hans-zho_Hant-devtest.hyp ${MODEL_WORKDIR}/flores200-devtest.cmn_Hans-cmn_Hant.output
	@touch $@



    # Czech (WMT 18, cs, ces_Latn)
    # German (WMT 14, de, deu_Latn)
    # Estonian (WMT 18, et, est_Latn)
    # Finnish (WMT 19, fi, fin_Latn)
    # French (WMT 14, fr, fra_Latn)
    # Gujarati (WMT 19, gu, guj_Gujr)
    # Hindi (WMT 14, hi, hin_Deva)
    # Kazakh (WMT 19, kk, kaz_Cyrl)
    # Lithuanian (WMT 19, lt, lit_Latn)
    # Standard Latvian (WMT 17, lv, lvs_Latn)
    # Romanian (WMT 16, ro, ron_Latn)
    # Russian (WMT 19, ru, rus_Cyrl)
    # Spanish (WMT 13, es, spa_Latn)
    # Turkish (WMT 18, tr, tur_Latn)
    # Chinese (simplified) (WMT 19, zh, zho_Hans).

wmt-ces-eng: ${MODEL_WORKDIR}/newstest2018.ces-eng.output ${MODEL_WORKDIR}/newstest2018.eng-ces.output
	${MAKE} -C .. ${MODEL_PARAM} TESTSETS=newstest2018 LANGPAIR=ces-eng eval
	${MAKE} -C .. ${MODEL_PARAM} TESTSETS=newstest2018 LANGPAIR=eng-ces eval

wmt-deu-eng: ${MODEL_WORKDIR}/newstest2014.deu-eng.output ${MODEL_WORKDIR}/newstest2014.eng-deu.output
	${MAKE} -C .. ${MODEL_PARAM} TESTSETS=newstest2014 LANGPAIR=deu-eng eval
	${MAKE} -C .. ${MODEL_PARAM} TESTSETS=newstest2014 LANGPAIR=eng-deu eval

wmt-est-eng: ${MODEL_WORKDIR}/newstest2018.est-eng.output ${MODEL_WORKDIR}/newstest2018.eng-est.output
	${MAKE} -C .. ${MODEL_PARAM} TESTSETS=newstest2018 LANGPAIR=est-eng eval
	${MAKE} -C .. ${MODEL_PARAM} TESTSETS=newstest2018 LANGPAIR=eng-est eval

# eng-fin is not the same in both directions! eng-fin is wrongly translated!

wmt-fin-eng: ${MODEL_WORKDIR}/newstest2019.fin-eng.output
	${MAKE} -C .. ${MODEL_PARAM} TESTSETS=newstest2019 LANGPAIR=fin-eng eval

wmt-fra-eng: ${MODEL_WORKDIR}/newstest2014.fra-eng.output ${MODEL_WORKDIR}/newstest2014.eng-fra.output
	${MAKE} -C .. ${MODEL_PARAM} TESTSETS=newstest2014 LANGPAIR=fra-eng eval
	${MAKE} -C .. ${MODEL_PARAM} TESTSETS=newstest2014 LANGPAIR=eng-fra eval

wmt-guj-eng: ${MODEL_WORKDIR}/newstest2019.guj-eng.output
	${MAKE} -C .. ${MODEL_PARAM} TESTSETS=newstest2019 LANGPAIR=guj-eng eval

wmt-hin-eng: ${MODEL_WORKDIR}/newstest2014.hin-eng.output ${MODEL_WORKDIR}/newstest2014.eng-hin.output
	${MAKE} -C .. ${MODEL_PARAM} TESTSETS=newstest2014 LANGPAIR=hin-eng eval
	${MAKE} -C .. ${MODEL_PARAM} TESTSETS=newstest2014 LANGPAIR=eng-hin eval

wmt-kaz-eng: ${MODEL_WORKDIR}/newstest2019.kaz-eng.output
	${MAKE} -C .. ${MODEL_PARAM} TESTSETS=newstest2019 LANGPAIR=kaz-eng eval

wmt-lit-eng: ${MODEL_WORKDIR}/newstest2019.lit-eng.output
	${MAKE} -C .. ${MODEL_PARAM} TESTSETS=newstest2019 LANGPAIR=lit-eng eval

wmt-lav-eng: ${MODEL_WORKDIR}/newstest2017.lav-eng.output ${MODEL_WORKDIR}/newstest2017.eng-lav.output
	${MAKE} -C .. ${MODEL_PARAM} TESTSETS=newstest2017 LANGPAIR=lav-eng eval
	${MAKE} -C .. ${MODEL_PARAM} TESTSETS=newstest2017 LANGPAIR=eng-lav eval

wmt-ron-eng: ${MODEL_WORKDIR}/newstest2016.ron-eng.output ${MODEL_WORKDIR}/newstest2016.eng-ron.output
	${MAKE} -C .. ${MODEL_PARAM} TESTSETS=newstest2016 LANGPAIR=ron-eng eval
	${MAKE} -C .. ${MODEL_PARAM} TESTSETS=newstest2016 LANGPAIR=eng-ron eval

wmt-rus-eng: ${MODEL_WORKDIR}/newstest2019.rus-eng.output
	${MAKE} -C .. ${MODEL_PARAM} TESTSETS=newstest2019 LANGPAIR=rus-eng eval


wmt-spa-eng: ${MODEL_WORKDIR}/newstest2013.spa-eng.output ${MODEL_WORKDIR}/newstest2013.eng-spa.output
	${MAKE} -C .. ${MODEL_PARAM} TESTSETS=newstest2013 LANGPAIR=spa-eng eval
	${MAKE} -C .. ${MODEL_PARAM} TESTSETS=newstest2013 LANGPAIR=eng-spa eval

wmt-tur-eng: ${MODEL_WORKDIR}/newstest2018.tur-eng.output ${MODEL_WORKDIR}/newstest2018.eng-tur.output
	${MAKE} -C .. ${MODEL_PARAM} TESTSETS=newstest2018 LANGPAIR=tur-eng eval
	${MAKE} -C .. ${MODEL_PARAM} TESTSETS=newstest2018 LANGPAIR=eng-tur eval


wmt-zho-eng: ${MODEL_WORKDIR}/newstest2019.zho-eng.output
	${MAKE} -C .. ${MODEL_PARAM} TESTSETS=newstest2019 LANGPAIR=zho-eng eval



non_flores_translations:
	wget -O $@.zip -qq https://tinyurl.com/nllbnonflorestranslations
	unzip $@.zip
	rm -f $@.zip

${MODEL_WORKDIR}/newstest2018.ces-eng.output:
	mkdir -p $(dir $@)
	mv non_flores_translations/wmt-ces_Latn-eng_Latn-test.hyp $@

${MODEL_WORKDIR}/newstest2018.eng-ces.output:
	mkdir -p $(dir $@)
	mv non_flores_translations/wmt-eng_Latn-ces_Latn-test.hyp $@


${MODEL_WORKDIR}/newstest2014.deu-eng.output:
	mkdir -p $(dir $@)
	mv non_flores_translations/wmt-deu_Latn-eng_Latn-test.hyp $@

${MODEL_WORKDIR}/newstest2014.eng-deu.output:
	mkdir -p $(dir $@)
	mv non_flores_translations/wmt-eng_Latn-deu_Latn-test.hyp $@



${MODEL_WORKDIR}/newstest2018.est-eng.output:
	mkdir -p $(dir $@)
	mv non_flores_translations/wmt-est_Latn-eng_Latn-test.hyp $@

${MODEL_WORKDIR}/newstest2018.eng-est.output:
	mkdir -p $(dir $@)
	mv non_flores_translations/wmt-eng_Latn-est_Latn-test.hyp $@



${MODEL_WORKDIR}/newstest2019.fin-eng.output:
	mkdir -p $(dir $@)
	mv non_flores_translations/wmt-fin_Latn-eng_Latn-test.hyp $@


${MODEL_WORKDIR}/newstest2014.fra-eng.output:
	mkdir -p $(dir $@)
	mv non_flores_translations/wmt-fra_Latn-eng_Latn-test.hyp $@

${MODEL_WORKDIR}/newstest2014.eng-fra.output:
	mkdir -p $(dir $@)
	mv non_flores_translations/wmt-eng_Latn-fra_Latn-test.hyp $@


${MODEL_WORKDIR}/newstest2019.guj-eng.output:
	mkdir -p $(dir $@)
	mv non_flores_translations/wmt-guj_Gujr-eng_Latn-test.hyp $@



${MODEL_WORKDIR}/newstest2014.hin-eng.output:
	mkdir -p $(dir $@)
	mv non_flores_translations/wmt-hin_Deva-eng_Latn-test.hyp $@

${MODEL_WORKDIR}/newstest2014.eng-hin.output:
	mkdir -p $(dir $@)
	mv non_flores_translations/wmt-eng_Latn-hin_Deva-test.hyp $@



${MODEL_WORKDIR}/newstest2019.kaz-eng.output:
	mkdir -p $(dir $@)
	mv non_flores_translations/wmt-kaz_Cyrl-eng_Latn-test.hyp $@

${MODEL_WORKDIR}/newstest2019.lit-eng.output:
	mkdir -p $(dir $@)
	mv non_flores_translations/wmt-lit_Latn-eng_Latn-test.hyp $@


${MODEL_WORKDIR}/newstest2017.lav-eng.output:
	mkdir -p $(dir $@)
	mv non_flores_translations/wmt-lvs_Latn-eng_Latn-test.hyp $@

${MODEL_WORKDIR}/newstest2017.eng-lav.output:
	mkdir -p $(dir $@)
	mv non_flores_translations/wmt-eng_Latn-lvs_Latn-test.hyp $@


${MODEL_WORKDIR}/newstest2016.ron-eng.output:
	mkdir -p $(dir $@)
	mv non_flores_translations/wmt-ron_Latn-eng_Latn-test.hyp $@

${MODEL_WORKDIR}/newstest2016.eng-ron.output:
	mkdir -p $(dir $@)
	mv non_flores_translations/wmt-eng_Latn-ron_Latn-test.hyp $@


${MODEL_WORKDIR}/newstest2019.rus-eng.output:
	mkdir -p $(dir $@)
	mv non_flores_translations/wmt-rus_Cyrl-eng_Latn-test.hyp $@


${MODEL_WORKDIR}/newstest2013.spa-eng.output:
	mkdir -p $(dir $@)
	mv non_flores_translations/wmt-spa_Latn-eng_Latn-test.hyp $@

${MODEL_WORKDIR}/newstest2013.eng-spa.output:
	mkdir -p $(dir $@)
	mv non_flores_translations/wmt-eng_Latn-spa_Latn-test.hyp $@


${MODEL_WORKDIR}/newstest2018.tur-eng.output:
	mkdir -p $(dir $@)
	mv non_flores_translations/wmt-tur_Latn-eng_Latn-test.hyp $@

${MODEL_WORKDIR}/newstest2018.eng-tur.output:
	mkdir -p $(dir $@)
	mv non_flores_translations/wmt-eng_Latn-tur_Latn-test.hyp $@


${MODEL_WORKDIR}/newstest2019.zho-eng.output:
	mkdir -p $(dir $@)
	mv non_flores_translations/wmt-zho_Hans-eng_Latn-test.hyp $@
