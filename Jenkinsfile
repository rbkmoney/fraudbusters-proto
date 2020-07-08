#!groovy
// -*- mode: groovy -*-

build('fraudbusters-proto', 'docker-host') {
    checkoutRepo()
    loadBuildUtils()

    def pipeDefault
    def gitUtils
    runStage('load pipeline') {
        env.JENKINS_LIB = "build_utils/jenkins_lib"
        pipeDefault = load("${env.JENKINS_LIB}/pipeDefault.groovy")
        pipeJavaProto = load("${env.JENKINS_LIB}/pipeJavaProto.groovy")
        gitUtils = load("${env.JENKINS_LIB}/gitUtils.groovy")
    }

    pipeDefault() {

        runStage('compile') {
            sh "make wc_compile"
        }

        env.skipSonar = 'true'
        pipeJavaProto()
    }
}
