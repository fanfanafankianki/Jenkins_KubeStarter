import jenkins.model.*
import hudson.model.*
import javaposse.jobdsl.plugin.*
import javaposse.jobdsl.dsl.*
import javaposse.jobdsl.plugin.JenkinsJobManagement
import javaposse.jobdsl.plugin.ExecuteDslScripts


// Sprawdzenie, czy plugin Job DSL jest zainstalowany
def jobDslPlugin = Jenkins.instance.pluginManager.getPlugin('job-dsl')
println "Start"
if (jobDslPlugin != null) {
    println "Job DSL plugin is installed. Proceeding with job creation."

    // Katalog ze skryptami Job DSL
    def dslScriptsDir = new File('/var/lib/jenkins/dsl_jobs')

    if (dslScriptsDir.exists() && dslScriptsDir.isDirectory()) {
        dslScriptsDir.eachFile { file ->
            if (file.name.endsWith('.groovy')) {
                println "Processing Job DSL script: ${file.name}"

                def scriptText = file.text

                // Użycie Job DSL do przetworzenia skryptu
                def jobManagement = new JenkinsJobManagement(System.out, [:], new File('.'))
                def dslScriptLoader = new DslScriptLoader(jobManagement)
                
                try {
                    dslScriptLoader.runScript(scriptText)
                    println "Successfully processed Job DSL script: ${file.name}"
                } catch (Exception e) {
                    println "Failed to process Job DSL script: ${file.name}. Error: ${e.message}"
                }
            }
        }
    } else {
        println "DSL scripts directory does not exist or is not a directory: ${dslScriptsDir}"
    }
} else {
    println "Job DSL plugin is not installed. Skipping job creation."
}
