FROM debian:buster
MAINTAINER info@viperdev.io

ENV DEBIAN_FRONTEND=noninteractive \
    ANDROID_HOME=/opt/android-sdk-linux \
    ANDROID_SDK_REV=4333796 \
    NPM_VERSION=6.12.0\
    IONIC_VERSION=5.4.0 \
    CORDOVA_VERSION=8.0.0 \
    YARN_VERSION=1.19.1 \
    GRADLE_VERSION=6.0 \
    DBUS_SESSION_BUS_ADDRESS=/dev/null

# Install basics
RUN set -x \
    && apt-get update \
    && apt-get install -y git wget curl unzip build-essential apt-transport-https ca-certificates dirmngr gnupg software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Install Node
RUN set -x \
    && curl -sL https://deb.nodesource.com/setup_10.x | bash - \
    && apt-get update \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install Node libraries and tools
RUN set -x \
    && npm install -g npm@"$NPM_VERSION" cordova@"$CORDOVA_VERSION" ionic@"$IONIC_VERSION" yarn@"$YARN_VERSION" \
    && mkdir Sources && mkdir -p /root/.cache/yarn/ \
    && npm cache clear --force

# Install Google Chrome
RUN set -x \
    && wget -O /tmp/google-chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    && dpkg --unpack /tmp/google-chrome.deb \
    && apt-get update \
    && apt-get install -f -y \
    && rm -rf /var/lib/apt/lists/* \
    && rm -f /tmp/google-chrome.deb

# Install fonts and libraries
RUN set -x \
    && apt-get update \
    && apt-get -qqy install fonts-ipafont-gothic xfonts-100dpi xfonts-75dpi xfonts-cyrillic xfonts-scalable libfreetype6 libfontconfig \
    && rm -rf /var/lib/apt/lists/*

# Install OpenJDK
RUN set -x \
    && curl -sL https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public | apt-key add - \
    && add-apt-repository --yes https://adoptopenjdk.jfrog.io/adoptopenjdk/deb/ \
    && apt-get update \
    && apt-get install -y adoptopenjdk-8-hotspot \
    && rm -rf /var/lib/apt/lists/*

# Install Android SDK Tools
RUN set -x \
    && echo ANDROID_HOME="${ANDROID_HOME}" >> /etc/environment \
    && dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y expect ant libc6-i386 lib32stdc++6 lib32gcc1 lib32ncurses6 lib32z1 qemu-kvm kmod \
    && mkdir /opt/android-sdk-linux && cd /opt/android-sdk-linux \
    && wget -O /tmp/android-tools-sdk.zip https://dl.google.com/android/repository/sdk-tools-linux-"$ANDROID_SDK_REV".zip \
    && unzip -q /tmp/android-tools-sdk.zip \
    && rm -f /tmp/android-tools-sdk.zip \
    && rm -rf /var/lib/apt/lists/*

# Install Gradle
RUN set -x \
    && mkdir  /opt/gradle && cd /opt/gradle \
    && wget -O /tmp/gradle.zip https://services.gradle.org/distributions/gradle-"$GRADLE_VERSION"-bin.zip \
    && unzip -q /tmp/gradle.zip \
    && rm -f /tmp/gradle.zip

# Setup environment
ENV PATH ${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools:/opt/gradle/gradle-${GRADLE_VERSION}/bin:${PATH}

# Install Android SDK packages and disable cordova telemetry
RUN yes Y | ${ANDROID_HOME}/tools/bin/sdkmanager --licenses \
    && cordova telemetry off

WORKDIR Sources
EXPOSE 8100 35729
CMD ["ionic", "serve"]
