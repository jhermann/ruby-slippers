# Debian / Ubuntu Java
function _clean_java_env {
    export MANPATH=$(sed -r -e 's~:/usr/lib/jvm/[^:]+~~g' -e 's/:+/:/g' -e 's/^:|:$//g' <<<":$MANPATH")
    test -n "$JAVA_HOME" && export PATH="$(tr : \\n <<<"$PATH" | grep -v ^$JAVA_HOME/ | tr \\n :)"
}
function usejava5 {
    _clean_java_env
    export JAVA_HOME="/usr/lib/jvm/java-1.5.0-sun"
    prependpathvar PATH $JAVA_HOME/jre/bin
    prependpathvar PATH $JAVA_HOME/bin
}
function usejava6 {
    _clean_java_env
    export JAVA_HOME="/usr/lib/jvm/java-6-sun"  # Prefer Oracle JVM if found
    test -d "$JAVA_HOME" || \
        export JAVA_HOME="/usr/lib/jvm/java-6-openjdk-$(dpkg-architecture -q DEB_HOST_ARCH)"
    prependpathvar PATH $JAVA_HOME/jre/bin
    prependpathvar PATH $JAVA_HOME/bin
}
function usejava7 {
    _clean_java_env
    export JAVA_HOME="/usr/lib/jvm/java-7-oracle"  # Prefer Oracle JVM if found
    test -d "$JAVA_HOME" || \
        export JAVA_HOME="/usr/lib/jvm/java-7-openjdk-$(dpkg-architecture -q DEB_HOST_ARCH)"
    prependpathvar PATH $JAVA_HOME/jre/bin
    prependpathvar PATH $JAVA_HOME/bin
    prependpathvar MANPATH "$JAVA_HOME/man"
    export MANPATH="${MANPATH%:}:"  # ensure it ends with ':'
}
function usejava8 {
    _clean_java_env
    export JAVA_HOME="/usr/lib/jvm/java-8-oracle"  # Prefer Oracle JVM if found
    test -d "$JAVA_HOME" || \
        export JAVA_HOME="/usr/lib/jvm/java-8-openjdk-$(dpkg-architecture -q DEB_HOST_ARCH)"
    prependpathvar PATH $JAVA_HOME/jre/bin
    prependpathvar PATH $JAVA_HOME/bin
    prependpathvar MANPATH "$JAVA_HOME/man"
    export MANPATH="${MANPATH%:}:"  # ensure it ends with ':'
}

function _usezuluX {  # Azul Zulu Certified OpenJDK
    _clean_java_env
    export JAVA_HOME="/usr/lib/jvm/zulu-$1-$(dpkg-architecture -q DEB_HOST_ARCH)"
    prependpathvar PATH "$JAVA_HOME/bin"
    prependpathvar MANPATH "$JAVA_HOME/man"
    export MANPATH="${MANPATH%:}:"  # ensure it ends with ':'
}
alias usezulu7='_usezuluX 7'
alias usezulu8='_usezuluX 8'
alias usezulu9='_usezuluX 9'
alias usezulu11='_usezuluX 11'

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

# Applications
alias plantuml="java -jar ${HOME}/.local/share/java/plantuml.jar"
