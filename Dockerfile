FROM ensemblorg/ensembl-vep:release_110.1 as build

USER root
RUN apt update && \
    apt install -y git autoconf libcurl4-openssl-dev && \
    git clone --recurse-submodules https://github.com/samtools/htslib.git && \
    git clone https://github.com/mawumag/bcftools.git && \
    cd bcftools && \
    autoheader && autoconf && ./configure && \
    make

FROM ensemblorg/ensembl-vep:release_110.1 as anno-vep

COPY --from=build /opt/vep/.vep/bcftools/bcftools /usr/local/bin/
COPY --from=build /opt/vep/.vep/bcftools/misc/color-chrs.pl /opt/vep/.vep/bcftools/misc/gff2gff.py /opt/vep/.vep/bcftools/misc/guess-ploidy.py /opt/vep/.vep/bcftools/misc/plot-vcfstats /opt/vep/.vep/bcftools/misc/plot-roh.py /opt/vep/.vep/bcftools/misc/run-roh.pl /opt/vep/.vep/bcftools/misc/vcfutils.pl /usr/local/bin/
COPY --from=build /opt/vep/.vep/bcftools/doc/bcftools.1 /usr/local/share/man/man1/
COPY --from=build /opt/vep/.vep/bcftools/plugins/*.so /usr/local/libexec/bcftools/

USER root

RUN apt update && \
    apt install -y python3 python3-pip zip && \
    pip3 install pandas xlsxwriter genmod

FROM anno-vep as anno-vep-db

RUN INSTALL.pl -a cfp --PLUGINS all -s homo_sapiens -y GRCh38