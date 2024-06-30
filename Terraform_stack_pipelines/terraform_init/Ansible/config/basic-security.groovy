import jenkins.model.*
import hudson.security.*
import hudson.util.*
import jenkins.install.*
import com.cloudbees.plugins.credentials.*
import com.cloudbees.plugins.credentials.domains.*
import com.cloudbees.plugins.credentials.impl.*

// Pobierz instancję Jenkinsa
def instance = Jenkins.getInstance()

// Ustawienia konta administratora
def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount("admin", "password")
instance.setSecurityRealm(hudsonRealm)

// Ustawienia strategii autoryzacji
def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
instance.setAuthorizationStrategy(strategy)
instance.save()

// Instalacja wtyczek
def pluginParameter = [
  "ant",
  "antisamy-markup-formatter",
  "apache-httpcomponents-client-4-api",
  "asm-api",
  "bootstrap5-api",
  "bouncycastle-api",
  "branch-api",
  "build-timeout",
  "caffeine-api",
  "checks-api",
  "cloudbees-folder",
  "commons-lang3-api",
  "commons-text-api",
  "configuration-as-code",
  "credentials-binding",
  "credentials",
  "dark-theme",
  "display-url-api",
  "durable-task",
  "echarts-api",
  "eddsa-api",
  "email-ext",
  "font-awesome-api",
  "git",
  "git-client",
  "github-api",
  "github-branch-source",
  "github",
  "gradle",
  "gson-api",
  "instance-identity",
  "ionicons-api",
  "jackson2-api",
  "jakarta-activation-api",
  "jakarta-mail-api",
  "javax-activation-api",
  "javax-mail-api",
  "jaxb",
  "jjwt-api",
  "job-dsl",
  "joda-time-api",
  "jquery3-api",
  "json-api",
  "json-path-api",
  "junit",
  "ldap",
  "mailer",
  "matrix-auth",
  "matrix-project",
  "metrics",
  "mina-sshd-api-common",
  "mina-sshd-api-core",
  "okhttp-api",
  "pam-auth",
  "pipeline-build-step",
  "pipeline-github-lib",
  "pipeline-graph-analysis",
  "pipeline-graph-view",
  "pipeline-groovy-lib",
  "pipeline-input-step",
  "pipeline-milestone-step",
  "pipeline-model-api",
  "pipeline-model-definition",
  "pipeline-model-extensions",
  "pipeline-stage-step",
  "pipeline-stage-tags-metadata",
  "plain-credentials",
  "plugin-util-api",
  "prism-api",
  "resource-disposer",
  "scm-api",
  "script-security",
  "snakeyaml-api",
  "ssh-credentials",
  "ssh-slaves",
  "structs",
  "theme-manager",
  "timestamper",
  "token-macro",
  "trilead-api",
  "variant",
  "workflow-aggregator",
  "workflow-api",
  "workflow-basic-steps",
  "workflow-cps",
  "workflow-durable-task-step",
  "workflow-job",
  "workflow-multibranch",
  "workflow-scm-step",
  "workflow-step-api",
  "workflow-support",
  "ws-cleanup"
].join(',')
def updateCenter = instance.getUpdateCenter()
updateCenter.updateAllSites()

def plugins = pluginParameter.split(",")
def pluginList = Arrays.asList(plugins)

def installed = false
pluginList.each {
  if (!instance.getPluginManager().getPlugin(it)) {
    updateCenter.getPlugin(it).deploy()
    installed = true
  }
}

if (installed) {
  instance.doSafeRestart()
}

// Oznaczenie instalacji jako zakończonej
InstallState.INITIAL_SETUP_COMPLETED.initializeState()
