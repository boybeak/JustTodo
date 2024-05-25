onPageReady()

function onPageReady() {
    document.getElementById('title-app-intention').textContent = lang.title_app_intention
    
    document.getElementById('text-app-intention-1').textContent = lang.text_app_intention_1
    
    const problemsList = document.getElementById('text-app-problems')
    lang.text_app_problems.forEach(problem => {
        const listItem = document.createElement('li')
        listItem.textContent = problem
        problemsList.appendChild(listItem)
    })

    document.getElementById('text-app-intention-2').textContent = lang.text_app_intention_2

    const answersList = document.getElementById('text-app-answers')
    lang.text_app_answers.forEach(answer => {
        const listItem = document.createElement('li')
        listItem.textContent = answer
        answersList.appendChild(listItem)
    })

    document.getElementById('title-app-open-source').textContent = lang.title_app_open_source
}