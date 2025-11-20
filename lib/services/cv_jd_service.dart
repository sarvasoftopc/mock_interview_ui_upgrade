
import 'package:flutter/material.dart';
import 'package:sarvasoft_moc_interview/providers/cv_jd_provider.dart';

class CvJDAnalysis{
  Future<void> performSkillAnalysis(BuildContext context, CvJdProvider cvJdProvider) async {
    if (cvJdProvider.cvText.isEmpty || cvJdProvider.jdText.isEmpty) return;
    await cvJdProvider.performSkillanalyis();
    if(cvJdProvider.error!=null ){
      if(cvJdProvider.error == "Session expired"){
        // Navigate to login screen if session expired
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Error'),
            content: Text(cvJdProvider.error!),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
      else{
        // Show error dialog
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Error'),
            content: Text(cvJdProvider.error!),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
    else {
      // Only navigate if we are NOT already on the skills screen
      final currentRoute = ModalRoute
          .of(context)
          ?.settings
          .name;
      if (currentRoute != '/skills') {
        Navigator.of(context).pushNamed('/skills');
      }
    }
  }
  Future<void> generateQuestions(BuildContext context, CvJdProvider cvJdProvider) async {
    if (cvJdProvider.cvText.isEmpty || cvJdProvider.jdText.isEmpty) return;
    await cvJdProvider.extractSkillsAndFetchQuestions();
    if(cvJdProvider.error!=null ){
     if(cvJdProvider.error == "Session expired"){
      // Navigate to login screen if session expired
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Error'),
          content: Text(cvJdProvider.error!),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false),
              child: const Text('OK'),
            ),
          ],
        ),
      );
     }
     else{
      // Show error dialog
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Error'),
          content: Text(cvJdProvider.error!),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
     }
    }
    else {
      // Only navigate if we are NOT already on the skills screen
      final currentRoute = ModalRoute
          .of(context)
          ?.settings
          .name;
      if (currentRoute != '/skills') {
        Navigator.of(context).pushNamed('/skills');
      }
    }
  }

}