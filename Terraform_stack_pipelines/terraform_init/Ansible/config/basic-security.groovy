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
def pluginParameter = ["git", "workflow-aggregator", "github", "configuration-as-code", "credentials", "plain-credentials", "job-dsl"].join(',')
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
