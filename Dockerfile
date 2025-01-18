FROM scratch

ADD root_contents.tar /
RUN /bin/sed -i 's/^UNRAIDLABEL="UNRAID"$/UNRAIDLABEL="UNRAID-DOCKER"/' /etc/rc.d/rc.S

CMD ["/bin/bash"]
