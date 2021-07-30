FROM maven:3.8.1-adoptopenjdk-8

# We need ruby to run pre-release.rb. Hopefully one day we'll get rid of that, but we're not there yet.
RUN apt-get update && apt-get install -y ruby bundler

RUN groupadd -r dev -g 1000 && useradd -g dev -u 1000 dev

RUN mkdir /release-scripts
RUN chmod a+rw /release-scripts

COPY *.sh /release-scripts/
COPY *.rb /release-scripts/
COPY Gemfile* /release-scripts/
RUN chmod -R a+rwX /release-scripts

WORKDIR /release-scripts
# Updating Gemfile.lock in the repository would break the release process of legacy branches,
# which runs on older VMs with an older version of bundler.
# So we just update Gemfile.lock here, inside the container.
RUN bundle update --bundler
RUN bundle config set system 'true'
RUN bundle install

USER dev
ENV PATH /release-scripts/:$PATH
ENV RUNNING_IN_HIBERNATE_RELEASE_CONTAINER 1

VOLUME /project
WORKDIR /project

CMD ["bash"]
