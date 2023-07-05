import { Application } from "@hotwired/stimulus"
import { definitionsFromContext } from "@hotwired/stimulus-webpack-helpers"
import appsignal from './appsignal';
import { installErrorHandler } from "@appsignal/stimulus"

const application = Application.start()
installErrorHandler(appsignal, application)
appsignal.addDecorator((span) => span.setTags({userId: "abc123"}))
const context = require.context("./controllers", true, /\.js$/)
application.load(definitionsFromContext(context))
