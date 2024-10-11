// This file is auto-generated by ./bin/rails stimulus:manifest:update
// Run that command whenever you add a new controller or create them with
// ./bin/rails generate stimulus controllerName

import { application } from "./application"

import PhraseController from "./phrase_controller"
import ExpandableController from "./expandable_controller"
import PhraseSuggestionController from "./phrase_suggestion_controller"

application.register("phrase", PhraseController)
application.register("expandable", ExpandableController)
application.register("phrase-suggestion", PhraseSuggestionController)
