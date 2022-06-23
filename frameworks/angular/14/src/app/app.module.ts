import { NgModule, ErrorHandler } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';

import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import appsignal from '../appsignal';
import { createErrorHandlerFactory } from '@appsignal/angular'

@NgModule({
  declarations: [
    AppComponent
  ],
  imports: [
    BrowserModule,
    AppRoutingModule
  ],
  providers: [
    {
      provide: ErrorHandler,
      useFactory: createErrorHandlerFactory(appsignal)
    }
  ],
  bootstrap: [AppComponent]
})
export class AppModule { }
