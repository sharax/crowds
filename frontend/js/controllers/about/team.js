app.controller('aboutTeamController', function($scope) {
    var teamArr = getTeam();
    $scope.teamSegments = segment(teamArr, 3);
    console.log($scope.teamSegments);

    function getTeam() {
        var team = [
            {
                name: "Sharad Goel",
                image: "Sharad-Goel",
                title: "Assistant Professor",
                description: "I’m an Assistant Professor at Stanford in the Management Science & Engineering Department (in the School of Engineering). I also have courtesy appointments in Sociology and Computer Science. My primary area of research is computational social science, an emerging discipline at the intersection of computer science, statistics, and the social sciences."
            },
            {
                name: "Imanol Arrieta",
                image: "Imanol-Arrieta",
                title: "PhD Student",
                description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."
            },
            {
                name: "Camelia Simoiu",
                image: "Camelia-Simoiu",
                title: "PhD Student",
                description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."
            }
        ];
        for(var i = 0; i < 16; i++) {
            team.push({
                name: "Another Name",
                image: "Sharad-Goel",
                title: "Another title",
                description: "Lorem ipsum dolor sit amet."
            });
            team.push({
                name: "Another Name",
                image: "Imanol-Arrieta",
                title: "Another title",
                description: "Lorem ipsum dolor sit amet."
            });
            team.push({
                name: "Another Name",
                image: "Camelia-Simoiu",
                title: "Another title",
                description: "Lorem ipsum dolor sit amet."
            });
        }
        team.push({
            name: "Another Name",
            image: "Sharad-Goel",
            title: "Another title",
            description: "Lorem ipsum dolor sit amet."
        });
        return team;
    }
});