<template>
  <vue-modal name="scorecard-modal" height="auto" width="80%" @before-open="beforeOpen">
    <div class="tornament-info-popup-header-top">
      <div class="row">
        <div class="col-md-4 first">
          <p>{{ scorecard.teeTimeAt }}</p>
        </div>
        <div class="col-md-4 center">
          <p>{{ scorecard.tournamentName }}</p>
        </div>
        <div class="col-md-4 last">
          <a href="#edit" class="btn btn__ezgl-secondary edit-button mr-2">Edit</a>
          <a href="#save" class="btn btn-primary mr-2">Save</a>
        </div>
      </div>
    </div>
    <div>
      <table>
        <thead>
          <tr>
            <th scope="col">Flight</th>
            <th scope="col">Hole<br>Yards</th>
            <template v-for="(holeGroup, j) in sliceScores(scorecard.holes)">
              <template v-for="hole in holeGroup">
                <th scope="col">{{ hole.holeNumber }}<br>{{ hole.yardForFlight }}</th>
              </template>
              <template v-if="j == 0">
                <th scope="col">Out</th>
              </template>
              <template v-else>
                <th scope="col">Out <br>In</th>
              </template>
            </template>
            <th scope="col">HDCP</th>
            <th scope="col">Gross <br>Net</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td>&nbsp;</td>
            <td>Par</td>
            <template v-for="(holeGroup, j) in sliceScores(scorecard.holes)">
              <template v-for="hole in holeGroup">
                <td>{{ hole.par }}</td>
              </template>
              <td>&nbsp;</td>
            </template>
          </tr>
          <tr class="score" v-for="card in scorecard.scorecards" :key="card.id">
            <td>{{ scorecard.flightName }}</td>
            <td>{{ card.name }}<br><a href="#disqualify" class="btn btn-primary edit">Disqualify</a></td>

            <template v-for="(scoreGroup, j) in sliceScores(card.scores)">
              <td v-for="score in scoreGroup">
                {{ score.score }}
                <template v-if="score.handicapStrokes != null">
                  <br/>
                  <span class="dot">
                    {{ score.handicapStrokes * -1 }}
                  </span>
                </template>
              </td>
              <template v-if="card.shouldSubtitle">
                <td v-if="j == 0" name="inner-subtitle">
                  {{ card.frontNineHandicapSubtotal }}
                </td>
                <td v-else name="outer-subtitle">
                  {{ card.frontNineHandicapSubtotal }}
                  <br>
                  {{ card.backNineHandicapSubtotal }}
                </td>
              </template>
              <template v-else>
                <td>&nbsp;</td>
              </template>
            </template>
            <td name="course-handicap">
              {{ card.courseHandicap }}
              <br/>
              <i class="fas fa-unlock edit"/>
            </td>
            <td name="total" v-if="card.shouldTotal">
              {{ card.grossTotal }}
              <br>
              <template v-if="card.netTotal > 0">
                {{ card.netTotal }}
              </template>
            </td>
            <td v-else>&nbsp;</td>
          </tr>
          <tr class="m-hcp">
            <td>M HCP</td>
            <td>&nbsp;</td>

            <template v-for="holeGroup in sliceScores(scorecard.holes)">
              <template v-for="hole in holeGroup">
                <td>{{ hole.handicap }}</td>
              </template>
              <td>&nbsp;</td>
            </template>
          </tr>
        </tbody>
      </table>
    </div>
  </vue-modal>
</template>

<script>
export default {
  data() {
    return {
      scorecard: {
        holes: [],
        scorecards: [
          {
            scores: [],
          },
        ],
      },
    };
  },
  methods: {
    beforeOpen(event) {
      this.scorecard = event.params.scorecard;
    },
    sliceScores(scores) {
      const sliceLength = scores.length / 2;
      const slices = scores.length / sliceLength;

      const sliced = [];

      for (let i = 0; i < slices; i += 1) {
        const start = i * sliceLength;
        const end = (i + 1) * sliceLength;
        const slice = scores.slice(start, end);

        sliced.push(slice);
      }

      return sliced;
    },
  },
};
</script>
