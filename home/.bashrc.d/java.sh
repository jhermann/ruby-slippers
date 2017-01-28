# Debian / Ubuntu Java
function usejava5 {
    test -n "$JAVA_HOME" && export PATH="$(tr : \\n <<<"$PATH" | grep -v ^$JAVA_HOME/ | tr \\n :)"
    export JAVA_HOME=/usr/lib/jvm/java-1.5.0-sun
    prependpathvar PATH $JAVA_HOME/jre/bin
    prependpathvar PATH $JAVA_HOME/bin
}
function usejava6 {
    test -n "$JAVA_HOME" && export PATH="$(tr : \\n <<<"$PATH" | grep -v ^$JAVA_HOME/ | tr \\n :)"
    export JAVA_HOME="/usr/lib/jvm/java-6-openjdk-$(dpkg-architecture -q DEB_HOST_ARCH)"
    test -d "$JAVA_HOME" || export JAVA_HOME="/usr/lib/jvm/java-6-sun"  # Prefer Oracle JVM if found
    prependpathvar PATH $JAVA_HOME/jre/bin
    prependpathvar PATH $JAVA_HOME/bin
}
function usejava7 {
    test -n "$JAVA_HOME" && export PATH="$(tr : \\n <<<"$PATH" | grep -v ^$JAVA_HOME/ | tr \\n :)"
    export JAVA_HOME="/usr/lib/jvm/java-7-openjdk-$(dpkg-architecture -q DEB_HOST_ARCH)"
    test -d "$JAVA_HOME" || export JAVA_HOME="/usr/lib/jvm/java-7-oracle"  # Prefer Oracle JVM if found
    prependpathvar PATH $JAVA_HOME/jre/bin
    prependpathvar PATH $JAVA_HOME/bin
    prependpathvar MANPATH "$JAVA_HOME/man"
    export MANPATH="${MANPATH%:}:"  # ensure it ends with ':'
}
function usejava8 {
    test -n "$JAVA_HOME" && export PATH="$(tr : \\n <<<"$PATH" | grep -v ^$JAVA_HOME/ | tr \\n :)"
    export JAVA_HOME="/usr/lib/jvm/java-8-openjdk-$(dpkg-architecture -q DEB_HOST_ARCH)"
    test -d "$JAVA_HOME" || export JAVA_HOME="/usr/lib/jvm/java-8-oracle"  # Prefer Oracle JVM if found
    prependpathvar PATH $JAVA_HOME/jre/bin
    prependpathvar PATH $JAVA_HOME/bin
    prependpathvar MANPATH "$JAVA_HOME/man"
    export MANPATH="${MANPATH%:}:"  # ensure it ends with ':'
}
function usezulu9 {  # Azul Zulu9 Certified OpenJDK
    test -n "$JAVA_HOME" && export PATH="$(tr : \\n <<<"$PATH" | grep -v ^$JAVA_HOME/ | tr \\n :)"
    export JAVA_HOME="/usr/lib/jvm/zulu-9-$(dpkg-architecture -q DEB_HOST_ARCH)"
    prependpathvar PATH "$JAVA_HOME/bin"
    prependpathvar MANPATH "$JAVA_HOME/man"
    export MANPATH="${MANPATH%:}:"  # ensure it ends with ':'
}

if test -z "$JAVA_HOME" -a -d /usr/lib/jvm/java-8-oracle/bin/javac; then
    usejava8
elif test -z "$JAVA_HOME" -a -d /usr/lib/jvm/java-7-oracle/bin/javac; then
    usejava7
elif test -z "$JAVA_HOME" -a -d /usr/lib/jvm/java-6-sun/bin/javac; then
    usejava6
fi

test ! -d /opt/tools/apache-maven-current \
    || export MAVEN_HOME=/opt/tools/apache-maven-current
export M2_REPO=$HOME/.m2/repository

# Maven aliases for bash completion of common goals
alias mvn-no-tests="mvn -Dmaven.test.skip=true"
alias mvn-skip-tests=mvn-no-tests
alias mvn-tests-skip=mvn-no-tests
for goal in dependency:tree eclipse:eclipse "clean package" help:effective-pom versions:update-parent; do
    alias mvn-$(sed -re "s/[^a-z]+/-/" <<<$goal)="mvn $goal"
done