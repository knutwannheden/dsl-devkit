/**
 * Copyright (c) 2016 Avaloq Evolution AG and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * Contributors:
 * Avaloq Evolution AG - initial API and implementation
 */
package com.avaloq.tools.ddk.check.validation

import org.eclipse.xtext.junit4.InjectWith
import org.junit.runner.RunWith
import org.eclipse.xtext.junit4.XtextRunner
import com.avaloq.tools.ddk.check.CheckUiInjectorProvider
import org.junit.Test
import com.google.inject.Inject
import org.eclipse.xtext.junit4.util.ParseHelper
import com.avaloq.tools.ddk.check.check.CheckCatalog
import org.eclipse.xtext.junit4.validation.ValidationTestHelper
import org.eclipse.xtext.xtype.XtypePackage

@InjectWith(typeof(CheckUiInjectorProvider))
@RunWith(typeof(XtextRunner))
class CheckApiAccessValidationsTest{

  @Inject
  ParseHelper<CheckCatalog> parser

  @Inject
  ValidationTestHelper helper

  def private getTestSource(String importText){
    return parser.parse('''
      package com.avaloq.example.stuff.checks
      import «importText»
      catalog CommonChecks
      for grammar com.avaloq.tools.ddk.check.TestLanguage
      {
      }'''
    )
  }

  @Test
  def public void testNonApiAccessDisallowed() {
    val model = getTestSource("com.avaloq.tools.ddk.check.check.impl.CheckImpl") //Not OK - impl not defined as API.
    helper.assertWarning(model, XtypePackage.Literals.XIMPORT_DECLARATION, IssueCodes.NON_API_IMPORTED)
  }

  @Test
  def public void testDefinedApiAccessable() {
    val model = getTestSource("com.avaloq.tools.ddk.check.check.Check") //OK! There's an API spec in this plugin's plugin.xml
    helper.assertNoIssue(model, XtypePackage.Literals.XIMPORT_DECLARATION, IssueCodes.NON_API_IMPORTED)
  }

  @Test
  def public void testNonAvaloqTypeAccessable() {
    val model = getTestSource("java.util.HashMap") //OK! Not in com.avaloq.*
    helper.assertNoIssue(model, XtypePackage.Literals.XIMPORT_DECLARATION, IssueCodes.NON_API_IMPORTED)
  }
}
