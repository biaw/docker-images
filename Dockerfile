# the openjdk image doesn't have curl and wget so we first need to use the alpine image (very small) to get the jar-file

FROM alpine AS builder
RUN apk add --no-cache curl wget

# specific version
ARG version="0.4.3-fixed"
ARG owner=noxianwill

# if version is latest then find the latest version on github, then download that version
RUN \
  if [ "$version" = "latest" ]; then version=$(curl -s https://api.github.com/repos/$owner/MusicBot/releases/latest | grep "tag_name" | cut -d '"' -f 4); fi && \
  wget https://github.com/$owner/MusicBot/releases/download/v$version/JMusicBot-$version.jar -O /JMusicBot.jar

# use Eclipse Temurin (Adoptium) instead of the deprecated openjdk image
FROM eclipse-temurin:11-jre-jammy AS runner
WORKDIR /data

# make an empty Playlists folder
RUN mkdir /data/Playlists

# copy the jar from the previous stage
COPY --from=builder /JMusicBot.jar /data/JMusicBot.jar

# run the bot
CMD ["java", "-Dnogui=true", "-jar", "JMusicBot.jar"]
