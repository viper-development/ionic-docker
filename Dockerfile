FROM debian:jessie
MAINTAINER marco [dot] turi [at] hotmail [dot] it

ENV DEBIAN_FRONTEND=noninteractive \
    ANDROID_HOME=/opt/android-sdk-linux \
    ANDROID_PLATFORM=26 \
    ASDK_TOOLS_VERSIONID=4333796 \
    ASDK_BUILD_TOOLS_VERSION=26.0.3 \
    NPM_VERSION=6.4.1 \
    IONIC_VERSION=3.20.0 \
    CORDOVA_VERSION=8.0.0 \
    YARN_VERSION=1.6.0 \
    GRADLE_VERSION=4.4.1 \
    # Fix for the issue with Selenium, as described here:
    # https://github.com/SeleniumHQ/docker-selenium/issues/87
    DBUS_SESSION_BUS_ADDRESS=/dev/null

# Install basics
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
    echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" >> /etc/sources.list && \
    echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get update &&  \
    apt-get install --force-yes -y expect git wget curl unzip build-essential \
      libc6-i386 lib32stdc++6 lib32gcc1 lib32ncurses5 lib32z1 qemu-kvm kmod \
      fonts-ipafont-gothic xfonts-100dpi xfonts-75dpi xfonts-cyrillic xfonts-scalable libfreetype6 libfontconfig \
      nodejs \
      oracle-java8-installer \
      && \
    npm install -g npm@"$NPM_VERSION" cordova@"$CORDOVA_VERSION" ionic@"$IONIC_VERSION" yarn@"$YARN_VERSION" && \
    npm cache clear --force && \
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    dpkg --unpack google-chrome-stable_current_amd64.deb && \
    apt-get install -f -y && \
    apt-get clean && \
    rm google-chrome-stable_current_amd64.deb && \
    mkdir Sources && \
    mkdir -p /root/.cache/yarn/ && \

# System libs for android enviroment
    echo ANDROID_HOME="${ANDROID_HOME}" >> /etc/environment && \

# Install Android Tools
    mkdir  /opt/android-sdk-linux && cd /opt/android-sdk-linux && \
    wget --output-document=android-tools-sdk.zip --quiet https://dl.google.com/android/repository/sdk-tools-linux-$ASDK_TOOLS_VERSIONID.zip && \
    unzip -q android-tools-sdk.zip && \
    rm -f android-tools-sdk.zip && \

# Install Gradle
    mkdir  /opt/gradle && cd /opt/gradle && \
    wget --output-document=gradle.zip --quiet https://services.gradle.org/distributions/gradle-"$GRADLE_VERSION"-bin.zip && \
    unzip -q gradle.zip && \
    rm -f gradle.zip && \
    chown -R root. /opt && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Setup environment
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools:/opt/gradle/gradle-${GRADLE_VERSION}/bin

# Install Android SDK
RUN yes Y | ${ANDROID_HOME}/tools/bin/sdkmanager "build-tools;$ASDK_BUILD_TOOLS_VERSION" "platforms;android-$ANDROID_PLATFORM" "platform-tools"
RUN cordova telemetry off

WORKDIR Sources
EXPOSE 8100 35729
CMD ["ionic", "serve"]
