<template>
  <vue-modal name="scorecard-modal" height="auto" width="80%" @before-open="beforeOpen" @before-close="beforeClose">
    <div class="tornament-info-popup-header-top">
      <div class="row">
        <div class="col-md-4 first">
          <p>{{ scorecard.teeTimeAt }}</p>
        </div>
        <div class="col-md-4 center">
          <p>{{ scorecard.tournamentName }}</p>
        </div>
        <div class="col-md-4 last">
          <a href="#edit" class="btn btn__ezgl-secondary edit-button mr-2" v-on:click="toggleEdit" v-if="!editMode">Edit</a>
          <a href="#save" class="btn btn-primary mr-2" v-on:click="saveScorecard">Save</a>
        </div>
      </div>
    </div>
    <div>
      <form onSubmit="return false">
        <table>
          <thead>
            <tr>
              <th scope="col">Flight</th>
              <th scope="col">Hole<br>Yards</th>
              <template v-for="(holeGroup, j) in sliceScores(scorecard.holes)">
                <template v-for="hole in holeGroup">
                  <th scope="col" v-bind:key="hole.holeNumber">{{ hole.holeNumber }}<br>{{ hole.yardForFlight }}</th>
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
              <template v-for="holeGroup in sliceScores(scorecard.holes)">
                <template v-for="hole in holeGroup">
                  <td v-bind:key="hole.holeNumber">{{ hole.par }}</td>
                </template>
                <td>&nbsp;</td>
              </template>
            </tr>
            <tr class="score" v-for="card in scorecard.scorecards" :key="card.id">
              <td>{{ scorecard.flightName }}</td>
              <td>{{ card.name }}<br><a href="#disqualify" class="btn btn-primary edit">Disqualify</a></td>

              <template v-for="(scoreGroup, j) in sliceScores(card.scores)">
                <td v-for="score in scoreGroup" v-bind:key="score.id">
                  <template v-if="editMode">
                    <input label="false" type="number" class="form-control string required" style="padding:0;" v-model.number="score.score">
                  </template>
                  <template v-else>
                    {{ score.score }}
                  </template>
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
                <template v-if="editMode">
                  <input label="false" type="number" class="form-control string required" style="padding:0;" v-model.number="card.courseHandicap">
                </template>
                <template v-else>
                  {{ card.courseHandicap }}
                </template>
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
      </form>
    </div>
  </vue-modal>
</template>

<script>
import api from 'api';

export default {
  data() {
    return {
      csrfToken: document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
      scorecard: {
        primaryScorecardId: null,
        holes: [],
        scorecards: [
          {
            scores: [],
          },
        ],
      },
      editMode: false,
    };
  },
  methods: {
    beforeOpen(event) {
      this.scorecard = event.params.scorecard;
    },
    beforeClose() {
      this.editMode = false;
    },
    toggleEdit() {
      this.editMode = !this.editMode;
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
    saveScorecard() {
      api.patchScorecard(this.csrfToken, this.scorecard)
        .then((response) => {
          window.location.reload();
        });
    },
  },
};
</script>
