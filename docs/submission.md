---
layout: tabbed-assignment
---

# Submission Instructions

After completing the lesson:

1. Make sure that you have:
   - Commited your changes to the **{{site.data.assignment.git-curr-branch}}** branch.
   - Pushed your work to GitHub.
   - Confirmed that you see your changes on GitHub.
1. Then, copy the link to your repository on GitHub.
1. Click the **Submit Assignment** button on Canvas.
1. Paste the link into the **Website URL** text box.

{% include submission-boilerplate.html %}

<!-- Don't edit links here, change them in _data/assignment.yml instead, -->

{% if site.data.assignment.lesson   %}[lesson]: <{{site.data.assignment.lesson}}>     {% endif %}
{% if site.data.assignment.slides   %}[slides]:   <{{site.data.assignment.slides}}>   {% endif %}
{% if site.data.assignment.template %}[template]: <{{site.data.assignment.template}}> {% endif %}
